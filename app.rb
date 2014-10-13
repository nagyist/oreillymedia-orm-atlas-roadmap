class AtlasRoadmap < Sinatra::Base

  enable :sessions

  set :github_options, {
    :scopes    => "repo",
    :secret    => ENV['GITHUB_CLIENT_SECRET'],
    :client_id => ENV['GITHUB_CLIENT_ID'],
  }

  register Sinatra::Auth::Github

  get '/test' do
    erb :test
  end

  get '/' do
    repo_name = ENV['PROJECT_PATH'] || 'oreillymedia/orm-atlas'
    github_organization_authenticate!('oreillymedia')

    @milestones = github_user.api.list_milestones(repo_name,{per_page:100}) + github_user.api.list_milestones(repo_name, {state:"closed",per_page:100})

    @releases = github_user.api.releases(repo_name)

    @data = Jbuilder.encode do |json|
      json.milestones @milestones do |milestone|
        json.open_issues    milestone.open_issues
        json.closed_issues  milestone.closed_issues
        json.state          milestone.state
        json.created_at     milestone.created_at.asctime
        json.updated_at     milestone.updated_at.asctime
        json.due_on         milestone.due_on ? milestone.due_on.asctime : nil
        json.title          milestone.title
        json.description    milestone.description
        json.number            milestone.number
      end
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
