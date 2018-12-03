require_relative 'spec_helper'

describe 'apache php' do
  it 'should have a php command' do
    expect(command('php -v').stdout).to include('7.0')
  end
end
