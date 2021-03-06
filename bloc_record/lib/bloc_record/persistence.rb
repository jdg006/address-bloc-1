require 'sqlite3'
require 'bloc_record/schema'
 
 module Persistence
 
   def self.included(base)
     base.extend(ClassMethods)
   end
   
   def save
     self.save! rescue false
   end
   
   def save!
       unless self.id
           self.id = self.class.create(BlocRecord::Utility.instance_variables_to_hash(self)).id
           BlocRecord::Utility.reload_obj(self)
           return true
       end
     fields = self.class.attributes.map { |col| "#{col}=#{BlocRecord::Utility.sql_strings(self.instance_variable_get("@#{col}"))}" }.join(",")
 
     self.class.connection.execute <<-SQL
       UPDATE #{self.class.table}
       SET #{fields}
       WHERE id = #{self.id};
     SQL
 
     true
   end
   
   def update_attribute(attribute, value)
     self.class.update(self.id, { attribute => value })
   end
   
   def update_attributes(updates)
     self.class.update(self.id, updates)
   end
   
   def destroy
     self.class.destroy(self.id)
   end
 
   module ClassMethods
       
      def update_all(updates)
        update(nil, updates)
      end
      
      def destroy_all(*options)
        
       if options && !options.empty?
          if options[0].class == Hash
            conditions_hash = BlocRecord::Utility.convert_keys(options[0])
            conditions = conditions_hash.map {|key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" and ")
         
          elsif options[0].class == String
            
            conditions = options[0]
            
          elsif options.count > 1
            key = options[0].delete!('?=')
            value = options[1]
            conditions = "#{key}= '#{value}'"
          else
           puts "Not a valid input"
          end
            connection.execute <<-SQL
              DELETE FROM #{table}
              WHERE #{conditions};
            SQL
         
       else
       connection.execute <<-SQL
           DELETE FROM #{table}
         SQL
       end
       true
      end
      
      def destroy(*id)
       if id.length > 1
         where_clause = "WHERE id IN (#{id.join(",")});"
       else
         where_clause = "WHERE id = #{id.first};"
       end
 
       connection.execute <<-SQL
         DELETE FROM #{table} #{where_clause}
       SQL
 
       true
      end
      
      def update_multiple(ids, updates)
          ids.count.times do |x| 
              update(ids[x], updates[x])
          end
      end
      
       
      def update(ids, updates)
          
          
           updates = BlocRecord::Utility.convert_keys(updates)
           updates.delete "id"
           updates_array = updates.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}" }
           
           if ids.class == Fixnum
             where_clause = "WHERE id = #{ids};"
           elsif ids.class == Array
             where_clause = ids.empty? ? ";" : "WHERE id IN (#{ids.join(",")});"
           else
             where_clause = ";"
           end
           
           connection.execute <<-SQL
             UPDATE #{table}
             SET #{updates_array * ","} #{where_clause}
           SQL
           true
           
      end 
      
     def create(attrs)
      
        if attrs.values.all? {|x| !x.nil? and !x.to_s.empty?} == false
          return 1
        end
     
       attrs = BlocRecord::Utility.convert_keys(attrs)
       attrs.delete "id"
       vals = attributes.map { |key| BlocRecord::Utility.sql_strings(attrs[key]) }
 
       connection.execute <<-SQL
         INSERT INTO #{table} (#{attributes.join ","})
         VALUES (#{vals.join ","});
       SQL
 
       data = Hash[attributes.zip attrs.values]
       data["id"] = connection.execute("SELECT last_insert_rowid();")[0][0]
       new(data)
     end
     
     def method_missing(sym, *args, &block)
         sym = sym.to_s
         if (/update_/ =~ sym) == 0 
           sym.slice!("update_")
           update_attribute(sym.to_sym, args[0])
          else
           "no method #{sym}"
         end
     end
     
   end
 end