require 'sinatra'
require 'haml'
require 'json'
require_relative 'sudokusolver'

get '/' do
	haml :index
end

post '/ajax/sudokusolver' do
  s = SudokuSolver.new
  solution = s.solve(params['g'])
  content_type :json
  if solution
    {:status => 'successful', :s => solution}.to_json
  else
    {:status => 'failed'}.to_json
  end
end