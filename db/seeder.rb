require 'sqlite3'

todos_db = SQLite3::Database.new("db/todos.db")
store_db = SQLite3::Database.new("db/store.db")


def seed!(todos_db, store_db)
  puts "Using db files: db/todos.db and db/store.db"
  puts "🧹 Dropping old tables..."
  drop_tables(todos_db, store_db)
  puts "🧱 Creating tables..."
  create_tables(todos_db, store_db)
  puts "🍎 Populating tables..."
  populate_tables(todos_db)
  puts "✅ Done seeding the database!"
end

def drop_tables(todos_db, store_db)
  todos_db.execute('DROP TABLE IF EXISTS todos')
  todos_db.execute('DROP TABLE IF EXISTS categories')
  store_db.execute('DROP TABLE IF EXISTS users')
end

def create_tables(todos_db, store_db)
  todos_db.execute('CREATE TABLE todos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL, 
              description TEXT,
              finished boolean, 
              category INTEGER)')

  todos_db.execute('CREATE TABLE categories (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category TEXT)')

  store_db.execute('CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL UNIQUE,
              password_digest TEXT NOT NULL)')
end

def populate_tables(db)
  db.execute('INSERT INTO todos (name, description, finished, category) VALUES ("Köp mjölk", "3 liter mellanmjölk, eko", false, 1)')
  db.execute('INSERT INTO todos (name, description, finished, category) VALUES ("Möte", "Möte med chefen kl. 12", false, 2)')
  db.execute('INSERT INTO todos (name, description, finished, category) VALUES ("Göra läxor", "Göra engelska läxor", false, 3)')

  db.execute('INSERT INTO categories (category) VALUES ("Private")')
  db.execute('INSERT INTO categories (category) VALUES ("Work")')
  db.execute('INSERT INTO categories (category) VALUES ("School")')
end

seed!(todos_db, store_db)