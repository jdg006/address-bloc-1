require 'sqlite3'
require 'pg'
 
 
 db = PG.connect(dbname: "address_bloc")
 
 db.exec("DROP TABLE IF EXISTS address_book;");
 db.exec("DROP TABLE IF EXISTS entry;");
 
 db.exec <<-SQL
     CREATE TABLE address_book (
       id INTEGER PRIMARY KEY,
       name VARCHAR(30)
     );
   SQL
 
 db.exec <<-SQL
     CREATE TABLE entry (
       id INTEGER PRIMARY KEY,
       address_book_id INTEGER,
       name VARCHAR(30),
       phone_number VARCHAR(30),
       email VARCHAR(30),
       FOREIGN KEY (address_book_id) REFERENCES address_book(id)
     );
   SQL