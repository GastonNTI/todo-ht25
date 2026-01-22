#app.rb
require 'sinatra'
require 'sqlite3'
require 'slim'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

post('/store') do 
    session[:key] = params[:username]
    redirect to('/view')
end

get('/view') do
    @name = session[:key]
end

get('/clear_session') do
 session.clear
 slim(:login)
end


post('/user/add') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    db = SQLite3::Database.new("db/store.db")
    result=db.execute("SELECT id FROM users WHERE username=?", username)
    
    if result.empty?
        if password==password_confirm
            password_digest=BCrypt::Password.create(password)
            db.execute("INSERT INTO users(username,password_digest) VALUES(?,?)", [username,password_digest])
            redirect('/welcome')
        else 
            redirect('/error') #Lösenord matchar ej
        end
    else redirect('/login') #User finns redan
    end
end



post('/login') do
    username = params[:username]
    password = params[:password]

    db = SQLite3::Database.new("db/store.db")
    db.results_as_hash = true
    result = db.execute("SELECT id, password_digest FROM users WHERE username=?", username)

    if result.empty?
        redirect('/error')
    end

    user_id = result.first["id"]
    password_digest = result.first["password_digest"]

    if BCrypt::Password.new(password_digest) == password
        session[:user_id] = user_id
        redirect('/welcome')
    else
        redirect('/error')
    end
end

get('/login') do
  slim(:login)
end

get('/') do
    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true
    @todos = db.execute("SELECT todos.*, categories.category FROM todos INNER JOIN categories ON todos.category = categories.id WHERE finished = 0")
    @finished_todos = db.execute("SELECT todos.*, categories.category FROM todos INNER JOIN categories ON todos.category = categories.id WHERE finished = 1")
    @categories = db.execute("SELECT * FROM categories")

    slim(:index)
end


post("/todos/add") do
    name = params[:name]
    description = params[:description]
    category = params[:category]

    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true
    category_id = db.execute("SELECT id FROM categories WHERE category = ?", category).first["id"]
    db.execute("INSERT INTO todos (name, description, finished, category) VALUES (?, ?, ?, ?)", [name, description, "0", category_id])

    redirect("/")
end


post("/categories/add") do
    category = params[:category]

    db = SQLite3::Database.new("db/todos.db")
    db.execute("INSERT INTO categories (category) VALUES (?)", category)

    redirect("/")
end


post("/categories/delete") do
    category = params[:category]

    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true

    todos = db.execute("SELECT todos.*, categories.category FROM todos INNER JOIN categories ON todos.category = categories.id")
    in_use = false
    todos.each do |todo|
        if todo["category"] == category
            in_use = true
            break
        end
    end

    if in_use == false
        db.execute("DELETE FROM categories WHERE category = ?", category)
    else
        p "Unable to delete category #{category} since it is currently in use."
    end

    redirect("/")
end


post("/todos/:id/delete") do
    id = params[:id]

    db = SQLite3::Database.new("db/todos.db")
    db.execute("DELETE FROM todos WHERE id = ?", id)

    redirect("/")
end


get("/:id/edit") do
    id = params[:id]

    db = SQLite3::Database.new("db/todos.db")
    db.results_as_hash = true
    @todos = db.execute("SELECT * FROM todos WHERE id = ?", id).first
    @categories = db.execute("SELECT * FROM categories")    

    slim(:edit)
end


post("/todos/:id/updates") do
  id = params[:id]
  name = params[:name]
  description = params[:description]
  category = params[:category]

  db = SQLite3::Database.new("db/todos.db")
  db.results_as_hash = true
  category_id = db.execute("SELECT id FROM categories WHERE category = ?", category).first["id"]
  db.execute("UPDATE todos SET name = ?, description = ?, category = ? WHERE id = ?", [name, description, category_id, id])

  redirect("/")
end


post("/:id/finished") do
    id = params[:id]
    finished = "1"

    db = SQLite3::Database.new("db/todos.db")
    db.execute("UPDATE todos SET finished = ? WHERE id = ?", [finished, id])

    redirect("/")
end