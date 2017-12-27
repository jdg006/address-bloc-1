require 'sqlite3'
 
 module Selection
  
  def find(*ids)
 
     if ids.length == 1
       find_one(ids.first)
     else
       rows = connection.execute <<-SQL
         SELECT #{columns.join ","} FROM #{table}
         WHERE id IN (#{ids.join(",")});
       SQL
 
       rows_to_array(rows)
     end
  end
   
   def find_one(id)
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       WHERE id = #{id};
     SQL
 
     init_object_from_row(row)
   end
   
   def find_by(attribute, value)
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
     SQL
 
     init_object_from_row(row)
   end
   
   def take(num=1)
     if num > 1
       rows = connection.execute <<-SQL
         SELECT #{columns.join ","} FROM #{table}
         ORDER BY random()
         LIMIT #{num};
       SQL
 
       rows_to_array(rows)
     else
       take_one
     end
   end
   
   def take_one
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY random()
       LIMIT 1;
     SQL
 
     init_object_from_row(row)
   end
   
   def first
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY id ASC LIMIT 1;
     SQL
 
     init_object_from_row(row)
   end
 
   def last
     row = connection.get_first_row <<-SQL
       SELECT #{columns.join ","} FROM #{table}
       ORDER BY id DESC LIMIT 1;
     SQL
 
     init_object_from_row(row)
   end
   
   def all
     rows = connection.execute <<-SQL
       SELECT #{columns.join ","} FROM #{table};
     SQL
 
     rows_to_array(rows)
   end
   
   def method_missing(sym, *args, &block)
     sym = sym.to_s
     if (/find_by_/ =~ sym) == 0 
       sym.slice!("find_by_")
       find_by(sym.to_sym, args[0])
      else
       "no method #{sym}"
     end
   end
   
   def find_each(options = {})
    
    batch_size = options[:batch_size]
    
    if !batch_size
     rows = connection.execute <<-SQL
       SELECT #{columns.join ","} FROM #{table};
     SQL
    else
      rows = connection.execute <<-SQL
       SELECT #{columns.join ","} FROM #{table} LIMIT #{batch_size};
       SQL
    end
      
      rows_to_array(rows).each do |entry|
       yield(entry)
     end
      
   end
   
   def find_in_batches(options={})
    start = options[:start]
    batch_size = options[:batch_size]
    
    rows = connection.execute <<-SQL
       SELECT #{columns.join ","} FROM #{table} LIMIT #{start}, #{batch_size};
     SQL
     
    yield(rows_to_array(rows))
   
   end

   
   private
   
   def init_object_from_row(row)
     if row
       data = Hash[columns.zip(row)]
       new(data)
     end
   end
   
   def rows_to_array(rows)
     rows.map { |row| new(Hash[columns.zip(row)]) }
   end
   
 end