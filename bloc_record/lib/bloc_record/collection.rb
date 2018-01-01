module BlocRecord
   class Collection < Array
     def update_all(updates)
       ids = self.map(&:id)
       self.any? ? self.first.class.update(ids, updates) : false
     end
     
     def take
         self[0]
     end
     
     def where(options = {})
         self.first.class.where(options)
     end
     
     def not(options={})
         
         key = options.keys[0]
         value = options[key]
         return_array = []
         
         self.each do |entry|
             entry_hash = Utility.instance_variables_to_hash(entry)
             if entry_hash[key.to_s] != value
                 return_array.push(entry)
             end
         end
          
         puts return_array
         
     end
     
   end
 end