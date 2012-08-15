module Express
  module AriaBilling
    class ApiHelper
      attr_accessor :auth_key, :client_no, :plans, :supp_plans, :usage_type

      def initialize(access_info=nil)
        if access_info != nil
          # no-op
        elsif defined? Rails
          access_info = Rails.application.config.billing[:aria]
        else
          raise Exception.new("Aria Billing Api Helper service is not initialized")
        end
        @auth_key = access_info[:config][:auth_key]
        @client_no = access_info[:config][:client_no]
        @plans = access_info[:plans]
        @supp_plans = access_info[:supp_plans]
        @usage_type = access_info[:usage_type]
      end

      def self.instance(access_info=nil)
        Express::AriaBilling::ApiHelper.new(access_info)
      end
     
      # NOTE: This method is only used for *Testing*
      def create_fake_acct(user_id, plan_name=nil)
        {
          'userid' => user_id,
          'password' => "nopass786",
          'master_plan_no' => get_plan_no(plan_name),
          'master_plan_units' => 1,
          'status_cd' => 1,
          'supp_field_names' => "RHLogin",
          'supp_field_values' => "#{user_id}",
          'first_name' => "Fname",
          'last_name' => "Lname",
          'company_name' => "Cname Inc",
          'address1' => "1234 Heaven Dr",
          'city' => "Mars City",
          'state_prov' => "CA",
          'postal_cd' => 99999,
          'country' => "US",
          'email' => "test@wontwork.com",
          'bill_first_name' => "BFname",
          'bill_last_name' => "BLname",
          'bill_company_name' => "BCname Inc",
          'bill_address1' => "6789 YellowStone",
          'bill_city' => "Moon city",
          'bill_state_prov' => "NC",
          'bill_postal_cd' => 88888,
          'bill_country' => "US",
          'bill_email' => "billtest@wontwork.com",
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "create_acct_complete"
        }
      end

      # NOTE: This method is only used for *Testing*
      def update_acct_contact(acct_no)
        {
          'account_no' => acct_no,
          'last_name' => "New Lname",
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "update_acct_contact"
        }
      end

      def update_acct_status(acct_no, status_cd=0)
        # STATUS CODES
        # 0  = Inactive
        # 1  = Active
        # -1 = Suspended
        # -2 = Cancelled
        # -3 = Terminated, etc.
        {
          'account_no' => acct_no,
          'status_cd' => status_cd,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "update_acct_status"
        }
      end

      def userid_exists(user_id)
        {
          'user_id' => user_id,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "userid_exists"
        }
      end

      def get_user_id_from_acct_no(acct_no)
        {
          'acct_no' => acct_no,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "get_user_id_from_acct_no"
        }
      end

      def get_acct_no_from_user_id(user_id)
        {
          'user_id' => user_id,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "get_acct_no_from_user_id"
        }
      end

      def record_usage(gear_uuid, sync_time, user_id=nil, acct_no=nil, 
                            usage_type=@usage_type[:gear][:small], usage_units=1)
        raise Express::AriaBilling::Exception.new "user_id or acct_no must be valid" if !user_id && !acct_no
        args = {
          'usage_units' => usage_units,
          'usage_date' => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
          'usage_type' => usage_type,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'qualifier_1' => gear_uuid,
          'qualifier_2' => sync_time.to_i,
          'rest_call' => "record_usage"
        }
        user_id ? args['userid']=user_id : args['acct_no']=acct_no
        args
      end

      def get_usage_history(acct_no, specified_usage_type_no=nil,
                            date_range_start=(Time.now-24*60*60).strftime("%Y-%m-%d"),
                            date_range_end=Time.now.strftime("%Y-%m-%d"))
        {
          'acct_no' => acct_no,
          'specified_usage_type_no' => specified_usage_type_no,
          'date_range_start' => date_range_start,
          'date_range_end' => date_range_end,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "get_usage_history"
        }
      end

      def get_acct_plans_all(acct_no)
        {
          'acct_no' => acct_no,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "get_acct_plans_all"
        }
      end
      
      def get_acct_details_all(acct_no)
        {
          'acct_no' => acct_no,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "get_acct_details_all"
        }
      end

      def update_master_plan(acct_no, plan_name,
                             num_plan_units=1, assignment_directive=2)
        {
          'acct_no' => acct_no,
          'master_plan_no' => get_plan_no(plan_name),
          'num_plan_units' => num_plan_units,
          'assignment_directive' => assignment_directive,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "update_master_plan"
        }
      end

      def assign_supp_plan(acct_no, supp_plan_name, 
                           num_plan_units=1, assignment_directive=2)
        {
          'acct_no' => acct_no,
          'supp_plan_no' => get_supp_plan_id(supp_plan_name),
          'num_plan_units' => num_plan_units,
          'assignment_directive' => assignment_directive,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "assign_supp_plan"
        }
      end

      def modify_supp_plan(acct_no, supp_plan_name,
                           num_plan_units=1, assignment_directive=2)
        {
          'acct_no' => acct_no,
          'supp_plan_no' => get_supp_plan_id(supp_plan_name),
          'num_plan_units' => num_plan_units,
          'assignment_directive' => assignment_directive,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "modify_supp_plan"
        }
      end

      def cancel_supp_plan(acct_no, supp_plan_name, assignment_directive=2)
        {
          'acct_no' => acct_no,
          'supp_plan_no' => get_supp_plan_id(supp_plan_name),
          'assignment_directive' => assignment_directive,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "cancel_supp_plan"
        }
      end

      def update_acct_supp_fields(acct_no, field_name, field_value)
        {
          'account_no' => acct_no,
          'field_name' => field_name,
          'value_text' => field_value,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "update_acct_supp_fields"
        }
      end

      private

      def get_plan_no(plan_id=nil)
        plan_no = @plans[:freeshift][:plan_no]
        if plan_id
          if @plans.include?(plan_id)
            plan_no = @plans[plan_id][:plan_no]
          else
            raise Express::AriaBilling::Exception.new "Invalid Billing Plan Id: #{plan_id}"
          end
        end
        plan_no
      end
      
      def get_plan_id_from_plan_no(plan_no)
        plan_id = nil
        @plans.each do |key, value|
          if value[:plan_no] == plan_no
            plan_id = key
          end
        end
        plan_id
      end

      def get_supp_plan_id(supp_plan_name)
        unless @supp_plans.include?(supp_plan_name)
          raise Express::AriaBilling::Exception.new "Invalid Billing Supplemental Plan name: #{supp_plan_name}"
        end
        @supp_plans[supp_plan_name][:plan_no]
      end
    end
  end
end
