require "bundler"
Bundler.require

get "/" do
  "Hi, I'm Bob!"
end

def travis
  session = Travis::Pro.session
  session.api_endpoint = "https://api.travis-ci.com"
  session.connection = adapter
  session.github_auth(ENV["GITHUB_API_KEY"])
end

def connection_adapter
  Faraday.new { |f| f.adapter :httpclient }
end
