require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'

enable :sessions

helpers do
    def current_user
        User.find_by(id: session[:user])
    end
end

before '/tasks' do
    if current_user.nil?
        redirect '/'
    end
end

get '/' do
    if current_user.nil?
        @tasks = Task.none
    else
        @tasks = current_user.tasks
    end
    erb :index
end

get '/signup' do
    erb :sign_up
end

post '/signup' do
    user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
    )
    if user.persisted?
        session[:user] = user.id
    end
    redirect '/'
end

get '/signin' do
    erb :sign_in
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
        session[:user] = user
    end
    redirect '/'
end

get '/logout' do
    session[:user] = nil
    redirect '/'
end
    
get '/tasks/new' do
    erb :new
end

post '/tasks' do
    date = params[:due_date].split('-')
    if Date.valid_date?(date[0].to_i, date[1].to_i, date[2].to_i)
        current_user.tasks.create(
            title: params[:title],
            due_date: Date.parse(params[:due_date])
        )
    else
        redirect '/tasks/new'
    end
    redirect '/'
end

post '/tasks/:id/done' do
    task = Task.find(params[:id])
    task.completed = true
    task.save
    redirect '/'
end

get '/tasks/:id/star' do
    task = Task.find(params[:id])
    task.star = !task.star
    task.save
    redirect '/'
end

post '/tasks/:id/delete' do
    task = Task.find(params[:id])
    task.destroy
    redirect '/'
end

get '/tasks/:id/edit' do
    @task = Task.find(params[:id])
    erb :edit
end

post '/tasks/:id' do
    task = Task.find(params[:id])
    date = params[:due_date].split('-')
    
    if Date.valid_date?(date[0].to_i, date[1].to_i, date[2].to_i)
        task.title = params[:title]
        task.due_date = Date.parse(params[:due_date])
        task.save
        redirect '/'
    else
        redirect "/tasks/#{task.id}/edit"
    end
end