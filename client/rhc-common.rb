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
    
    def RHC.check_namespace(namespace)
        check_field(namespace, 'namespace')
    end
    
    def RHC.check_app(app)
        check_field(app, 'application')
    end
    
    def RHC.check_field(field, type)
        if field
            if field =~ /[^0-9a-zA-Z]/
                puts "#{type} contains non-alphanumeric characters!"
                return false
            end
        else
            puts "#{type} is required"
            return false
        end
        true
    end
    
    def RHC.get_type(type)
        if type   
            if !(RHC::TYPES.has_key?(type))        
                puts 'type must be ' << RHC::get_type_keys(' or ')
            else
                return RHC::TYPES[type]
            end
        else
            puts "Type is required"
        end
        nil
    end      
    
end