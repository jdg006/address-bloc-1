module BlocRecord
   def self.connect_to(filename, sql_type)
     @database_filename = filename
     @sql_type = sql_type
   end
 
   def self.database_filename
     @database_filename
   end
 end