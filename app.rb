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
    @milestones = github_user.api.list_milestones(repo_name) + github_user.api.list_milestones(repo_name, {state:"closed"})
    @releases = github_user.api.releases(repo_name)

    @data = Jbuilder.encode do |json|
      json.milestones @milestones,
        :open_issues, :closed_issues, :state, :created_at,
        :due_on, :title, :description, :url
      json.releases @releases,
        :html_url, :tag_name, :name, :body, :published_at,
        :draft, :prerelease, :created_at
    end
    erb :index
  end

  get '/logout' do
    logout!
    "logged out"
  end
end
