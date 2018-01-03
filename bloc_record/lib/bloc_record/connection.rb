require 'sqlite3'
require 'pg'
 
 module Connection
   def connection
    if BlocRecord.sql_type == :sqlite3
      @connection ||= SQLite3::Database.new(BlocRecord.database_filename)
    elsif BlocRecord.sql_type == :pg
      @connection ||= PG::Connection.open(:dbname => BlocRecord.database_filename)
    else
       "Unsupported sql type"
    end
   
   end
 end