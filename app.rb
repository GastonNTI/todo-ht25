require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'





# Routen /
get('/') do
    slim(:index)
end

get('/todo') do
    slim(:todo)
end

get('/kategori') do
    slim(:kategori)
end