require "bundler"
Bundler.require
Dotenv.load

get "/" do
  "Hi, I'm Bob!"
end

get "/builds" do
  @recent_builds = builds.map do |build|
    { number: build.number, state: build.state, failures: find_failures(build) }
  end

  haml :builds
end

def find_failures(build)
  return nil unless build.state == "failed"

  body = build.jobs.first.log.clean_body

  start_delimiter = "Failed examples:"
  end_delimiter = "Randomized"

  failures = body[/#{start_delimiter}(.*?)#{end_delimiter}/m, 1]
end

def builds
  @builds ||= repo.builds(after_number: last_build - 25)
end

def last_build
  @last_build ||= repo.last_build.number.to_i
end

def repo
  @repo ||= travis.repo("#{ENV["GITHUB_ORGANIZATION"]}/#{ENV["GITHUB_REPO"]}")
end

def travis
  @session ||= begin
    session = Travis::Pro.session
    session.connection = connection_adapter
    session.api_endpoint = "https://api.travis-ci.com"
    session.github_auth(ENV["GITHUB_API_KEY"])

    session
  end
end

def connection_adapter
  Faraday.new { |f| f.adapter :httpclient }
end
