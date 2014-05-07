class AtlasRoadmap < Sinatra::Base

  enable :sessions

  set :github_options, {
    :scopes    => "repo",
    :secret    => ENV['GITHUB_CLIENT_SECRET'],
    :client_id => ENV['GITHUB_CLIENT_ID'],
  }

  register Sinatra::Auth::Github

  get '/' do
    repo_name = 'oreillymedia/orm-atlas'
    github_organization_authenticate!('oreillymedia')
    @milestones = github_user.api.list_milestones(repo_name)
    @releases = github_user.api.releases(repo_name)
    @issues = github_user.api.list_issues(repo_name)
    erb :index
  end

  get '/logout' do
    logout!
    "logged out"
  end
end
