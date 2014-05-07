require 'bundler'
Bundler.require
require 'pp'

require './app'

app = Rack::Builder.new do
  map ('/') {run AtlasRoadmap}
  map '/assets' do
    environment = Sprockets::Environment.new
    # environment.append_path 'assets/javascripts'
    environment.append_path 'assets/stylesheets'
    run environment
  end
end

run app
