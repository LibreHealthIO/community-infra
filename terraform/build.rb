#!/usr/bin/env ruby
require 'rubygems' # ruby1.9 doesn't "require" it though
require 'thor'
require 'rbconfig'
require 'fileutils'
require 'json'
require 'erb'

def os
  case RbConfig::CONFIG['host_os']
  when /mswin|windows/i
    :windows
  when /linux|arch/i
    :linux
  when /darwin/i
    :darwin
  else
    abort("Unsupported OS #{RbConfig::CONFIG['host_os']}")
  end
end

$terraform_version = '0.11.0'
$terraform_url = "https://releases.hashicorp.com/terraform/#{$terraform_version}/terraform_#{$terraform_version}_#{os}_amd64.zip"
$tmp_dir = '.tmp/bin'
$excluded_dirs = ['conf/', 'modules/']
$pwd = Dir.pwd

class Build < Thor
  desc 'clean', 'Clean all folders'
  def clean
    puts 'Cleaning temp folder'
    FileUtils.rm_rf($tmp_dir)
    puts 'Cleaning .terraform folders'
    Dir['**/.terraform/'].each { |x| FileUtils.rm_rf(x) }
  end

  desc 'install', 'Install required dependencies.'
  def install
    puts "Running on: #{os}"
    FileUtils.mkdir_p '.tmp/bin'
    puts "\n\n\nAttempting to decrypt secrets using GPG key."
    system('git-crypt unlock') || abort('Error when attempting to decrypt secrets')
    system('chmod 600 conf/provisioning/ssh/terraform-api.key') || abort('Error when setting private key permissions')
    system("wget -vvvv -O #{$tmp_dir}/terraform.zip #{$terraform_url}") || abort('Error when downloading terraform')
    system("cd #{$tmp_dir} && unzip terraform.zip") || abort('Error when unzipping terraform')
    FileUtils.cp('conf/openrc-personal-example', 'conf/openrc-personal') unless File.exist?('conf/openrc-personal')
    puts "\n\n\n*** Please edit conf/openrc-personal with your credentials. ***\n\n"
  end

  desc 'init_all', 'Run terraform init in all subfolders'
  def init_all
    (Dir['*/'] - $excluded_dirs).each do |d|
      puts "Running terraform init on #{d}"
      system("source conf/openrc && cd #{d} && #{$pwd}/#{$tmp_dir}/terraform init -force-copy") || abort
    end
  end

  desc 'init DIR', 'Run terraform init on DIR'
  def init(dir)
    puts "Running terraform init on #{dir}"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform init -force-copy") || abort
  end

  desc 'plan DIR', 'run terraform plan on defined directory'
  def plan(dir)
    puts "Running terraform plan on #{dir}"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform plan -out terraform.plan") || abort
  end

  desc 'apply DIR', 'run terraform apply on defined directory'
  def apply(dir)
    puts "Terraform apply is NOT thread-safe, and there's no lock mechanism enabled. Two concurrent calls on the same stack will cause inconsistences."
    printf "Do you really want to modify stack #{dir}? [y/N]:  "
    prompt = STDIN.gets.chomp
    return unless prompt == 'y'

    puts "Running terraform apply on #{dir}"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform apply terraform.plan") || abort
  end

  desc 'taint-vm DIR', 'mark virtual machine for recreation in DIR'
  def taint_vm(dir)
    puts "Running terraform taint on #{dir} (vm resources)"
    system(''"source conf/openrc && cd #{dir} \
      && #{$pwd}/#{$tmp_dir}/terraform taint -module single-machine openstack_compute_instance_v2.vm \
      && #{$pwd}/#{$tmp_dir}/terraform taint -module single-machine openstack_compute_volume_attach_v2.attach_data_volume || true \
      && #{$pwd}/#{$tmp_dir}/terraform taint -module single-machine null_resource.mount_data_volume || true \
      && #{$pwd}/#{$tmp_dir}/terraform taint -module single-machine null_resource.setup-dns \
      && #{$pwd}/#{$tmp_dir}/terraform taint -module single-machine null_resource.upgrade \
      && #{$pwd}/#{$tmp_dir}/terraform taint -module single-machine null_resource.copy_facts \
      && #{$pwd}/#{$tmp_dir}/terraform taint -module single-machine null_resource.ansible || true \
    "'') || abort
  end

  desc "terraform DIR 'subcommand --args'", 'run arbitrary terraform subcommands on defined directory'
  def terraform(dir, args)
    puts "Running terraform \'#{args}\' on #{dir}"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform #{args}") || abort
  end

  desc 'create DIR', 'creates files for new stack DIR'
  def create(dir)
    puts "Creating stack \'#{dir}\'"
    FileUtils.mkdir_p dir
    FileUtils.cp_r 'conf/template-stack/.', dir
    IO.write("#{dir}/main.tf", File.open("#{dir}/main.tf") do |f|
                                 f.read.gsub(/STACK-NAME/, dir.to_s)
                               end)
    IO.write("#{dir}/variables.tf", File.open("#{dir}/variables.tf") do |f|
                                      f.read.gsub(/STACK-NAME/, dir.to_s)
                                    end)
    FileUtils.ln_sf '../global-variables.tf', "#{dir}/global-variables.tf"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform init") || abort
  end

  desc 'docs', 'generate docs in .tmp/docs.md'
  def docs
    $extra_excluded_dirs = $excluded_dirs.push('base-network/', 'docs/')

    $vms = []

    File.open('.tmp/docs.md', 'w') do |_file|
      (Dir['*/'] - $extra_excluded_dirs).each do |d|
        puts "Retrieving outputs for #{d}"
        outputs = `source conf/openrc && cd #{d} && #{$pwd}/#{$tmp_dir}/terraform output -json`
        outputs_parsed = JSON.parse(outputs)
        provisioner = outputs_parsed['provisioner']['value']

        next unless provisioner == 'terraform'
        vm_name = d.chomp('/')
        puts "Found terraformed machine #{vm_name}"
        vm = {
          'name'        => vm_name,
          'environment' => outputs_parsed['ansible_inventory']['value'],
          'data_center' => outputs_parsed['region']['value'],
          'size'        => outputs_parsed['flavor']['value'],
          'backup'      => outputs_parsed['has_backup']['value'] == '1' ? 'Yes' : 'No',
          'data_volume' => outputs_parsed['has_data_volume']['value'] == '1' ? "Yes (#{outputs_parsed['data_volume_size']['value']}GB)" : 'No',
          'ip'          => outputs_parsed['ip_address']['value'],
          'dns'         => outputs_parsed['dns_entries']['value'],
          'description' => outputs_parsed['description']['value']
        }
        if outputs_parsed['dns_manual_entries']
          vm['manual_dns'] = outputs_parsed['dns_manual_entries']['value']
        end
        $vms.push(vm)
      end
    end

    file_output = 'docs/vms.html'
    erb_str = File.read('conf/docs.erb')
    File.open(file_output, 'w') do |f|
      f.write(ERB.new(erb_str).result)
    end
    puts "File generated in #{file_output}."

    file_output = 'docs/vms.json'
    File.open(file_output, 'w') do |f|
      f.write(JSON.pretty_generate($vms))
    end
    puts "File generated in #{file_output}."

    puts "\n\n\n\n"
    puts 'Update stack <docs> to upload it to S3. '
  end
end

Build.start
