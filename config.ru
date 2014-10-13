require 'bundler'
Bundler.require
require './app'

#app = Rack::Builder.new do
#  map ('/') {run AtlasRoadmap}
#  map '/assets' do
#    environment = Sprockets::Environment.new
#    environment.append_path 'assets/javascripts'
#    environment.append_path 'assets/templates'
#    environment.append_path 'assets/stylesheets'
#    run environment
#  end
#end

run AtlasRoadmap
