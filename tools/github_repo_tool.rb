require 'dotenv'
Dotenv.load

require 'octokit'

client = Octokit::Client.new(access_token: ENV['GITHUB_API_KEY'], per_page: 200)

client.repositories('librehealthio').each do |repo|
  name = repo.name
  if name =~ /lh-ehr-*/
    client.update_repository "LibreHealthIO/#{repo.name}",
                             has_issues: true,
                             has_wiki: true,
                             has_projects: true,
                             has_downloads: true
  end
  unless name =~ /lh-ehr-*/
    client.update_repository "LibreHealthIO/#{repo.name}",
                             has_issues: false,
                             has_wiki: false,
                             has_projects: false,
                             has_downloads: true
  end
  if name =~ /community-*/
    client.update_repository "LibreHealthIO/#{repo.name}",
                             has_downloads: false
  end
end
