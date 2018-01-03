require 'sqlite3'
require 'pg'
require 'bloc_record/utility'
 
 module Schema
    
    def table
     BlocRecord::Utility.underscore(name)
    end
    
    def schema
     unless @schema
       @schema = {}
       
      if connection.class == PG::Connection
       
         res = connection.query("select * from #{table}")
         res.fields.each do |x|
          oid = res.fnumber(x)
          typename = connection.exec("SELECT format_type($1,$2)", [res.ftype(oid), res.fmod(oid)]).getvalue(0,0)
          @schema[x] = typename
         end
         
      elsif connection.class == SQLite3::Database
        
         connection.table_info(table) do |col|
           @schema[col["name"]] = col["type"]
         end
        
      else
      end
       
     end
     
    puts @schema
    @schema
    
    end
    
    def columns
     schema.keys
    end
    
    def attributes
     columns - ["id"]
    end 
   
    def count
     connection.execute(<<-SQL)[0][0]
       SELECT COUNT(*) FROM #{table}
     SQL
    end
   
 end