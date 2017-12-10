require 'dotenv'
Dotenv.load

require 'octokit'

client = Octokit::Client.new(access_token: ENV['GITHUB_API_KEY'], per_page: 200)

client.repositories('librehealthio').each do |repo|
  next if repo.name === 'LibreEHR'
  client.update_repository "LibreHealthIO/#{repo.name}", has_issues: false, has_wiki: false, has_projects: false, has_downloads: true
  client.update_repository "LibreHealthIO/#{repo.name}", has_downloads: false if repo.name =~ /community-*/
end
