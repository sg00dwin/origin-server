#--
# Copyright 2010 Red Hat, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#++


require 'rubygems'
require 'active_model'
require 'cloud-sdk-engine/config'
require 'cloud-sdk-engine/utils/shell_exec'

module Cloud
  module SDK
    module Model
      class AccessDeniedException < Exception
        def initialize(message)
          @message = message
        end
      end
      
      class CdkModel
        extend ActiveModel::Naming        
        include ActiveModel::Observing
        include ActiveModel::Validations
        include ActiveModel::Conversion
        
        def self.gen_uuid
          fp = File.new("/proc/sys/kernel/random/uuid", "r")
          uuid =  fp.gets.strip.gsub!("-","")
          fp.close
          uuid
        end
        
        def self.create_bucket(bucket)
        end
        
        def self.grant_bucket_access(bucket,uid)
        end
        
        def self.find
        end
        
        def self.find_all
        end
        
        def self.find_all_keys
        end
                
        def save!
          @persisted = true
        end
        
        def delete!
        end

        def persisted?
          self.persisted
        end
        attr_reader :uuid, :persisted
      end
    end
  end
end
