module RHC

    TYPES = { "php-5.3.2" => :php,
        "rack-1.1.0" => :rack,
        "wsgi-3.2.1" => :wsgi
    }
    
    def RHC.get_type_keys(sep)
        i = 1
        type_keys = ''
        TYPES.each_key do |key|
            type_keys += key
            if i < TYPES.size
                type_keys += sep
            end
            i += 1
        end
        type_keys
    end
    
    def RHC.check_user(user)
        check_field(user, 'username')
    end
    
    def RHC.check_app(app)
        check_field(app, 'application')
    end
    
    def RHC.check_field(field, type)
        if field
            if field =~ /[^0-9a-zA-Z]/
                puts "application name contains non-alphanumeric characters!"
                return false
            end
        else
            puts "Libra #{type} name is required"
        end
        true
    end
    
    def RHC.get_type(type)
        if type   
            if !(RHC::TYPES.has_key?(type))        
                puts 'type must be ' << RHC::get_type_keys(' or ')
                return nil;
            else
                return RHC::TYPES[type]
            end
        else
            puts "Type is required"
        end
         nil
    end      
    
end