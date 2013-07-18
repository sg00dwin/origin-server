module OpenShift
  class AriaApiHelper
    attr_accessor :auth_key, :client_no, :plans, :supp_plans, :usage_type

    def initialize(access_info=nil)
      if access_info != nil
        # no-op
      elsif defined? Rails
        access_info = Rails.application.config.billing
      else
        raise Exception.new("Aria Billing Api Helper service is not initialized")
      end
      @auth_key = access_info[:config][:auth_key]
      @client_no = access_info[:config][:client_no]
      @plans = access_info[:plans]
      @supp_plans = access_info[:supp_plans] || []
      @usage_type = access_info[:usage_type]
    end

    def self.instance(access_info=nil)
      OpenShift::AriaApiHelper.new(access_info)
    end
   
    # NOTE: This method is only used for *Testing*
    def create_fake_acct(login, plan_name=nil)
      user_id = Digest::MD5::hexdigest(login)
      {
        'userid' => user_id,
        'password' => "nopass786",
        'master_plan_no' => get_plan_no(plan_name),
        'master_plan_units' => 1,
        'status_cd' => 1,
        'supp_field_names' => "RHLogin",
        'supp_field_values' => "#{login}",
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

    def record_usage(acct_no, usage_type, usage_unit, gear_id, app_name,
                     sync_time, sync_identifier, usage_date)
      if acct_no.nil? or usage_type.nil? or usage_unit.nil? or gear_id.nil? or
         app_name.nil? or sync_time.nil? or sync_identifier.nil? or usage_date.nil?
        raise OpenShift::AriaException.new "Invalid input: One of the arg has nil"
      end 
      args = {
        'acct_no' => acct_no,
        'usage_type' => usage_type,
        'usage_units' => usage_unit,
        'usage_date' => usage_date,
        'qualifier_1' => gear_id,
        'qualifier_2' => app_name,
        'qualifier_3' => sync_time.to_i,
        'qualifier_4' => sync_identifier.to_i,
        'client_no' => @client_no,
        'auth_key' => @auth_key,
        'rest_call' => "record_usage"
      }
      args
    end

    def bulk_record_usage(acct_nos, usage_types, usage_units, gear_ids, app_names,
                          sync_time, sync_identifiers, usage_dates)
      len = acct_nos.size
      if (usage_types.size != len) or (usage_units.size != len) or (gear_ids.size != len) or 
         (app_names.size != len) or (sync_identifiers.size != len) or (usage_dates.size != len)
        raise OpenShift::AriaException.new "Invalid input: array length mismatch"
      end
      if acct_nos.include?(nil) or usage_types.include?(nil) or usage_units.include?(nil) or
         gear_ids.include?(nil) or app_names.include?(nil) or sync_time.nil? or
         sync_identifiers.include?(nil) or usage_dates.include?(nil)
        raise OpenShift::AriaException.new "Invalid input: array has nil"
      end
      sync_times = []
      sync_time = sync_time.to_i
      len.times { sync_times << sync_time }
      args = {
        'acct_no' => acct_nos.join('|'),
        'usage_type' => usage_types.join('|'),
        'usage_units' => usage_units.join('|'),
        'usage_date' => usage_dates.join('|'),
        'qualifier_1' => gear_ids.join('|'),
        'qualifier_2' => app_names.join('|'),
        'qualifier_3' => sync_times.join('|'),
        'qualifier_4' => sync_identifiers.join('|'),
        'client_no' => @client_no,
        'auth_key' => @auth_key,
        'rest_call' => "bulk_record_usage"
      }
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
                           is_upgrade=false, num_plan_units=1)
      if is_upgrade
        assignment_directive = 2
      else
        assignment_directive = 1
      end
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
 
    def write_acct_comment(acct_no, comment)
      {
        'acct_no' => acct_no,
        'client_no' => @client_no,
        'auth_key' => @auth_key,
        'comment' => comment,
        'rest_call' => "write_acct_comment"
      }
    end
 
    def get_queued_service_plans(acct_no)
      {
        'account_number' => acct_no,
        'client_no' => @client_no,
        'auth_key' => @auth_key,
        'rest_call' => "get_queued_service_plans"
      }
    end

    def cancel_queued_service_plan(acct_no)
      {
        'account_number' => acct_no,
        'client_no' => @client_no,
        'auth_key' => @auth_key,
        'rest_call' => "cancel_queued_service_plan"
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

    def get_virtual_datetime()
      {
        'client_no' => @client_no,
        'auth_key' => @auth_key,
        'rest_call' => "get_virtual_datetime"
      }
    end

    private

    def get_plan_no(plan_id=nil)
      plan_no = @plans[:free][:plan_no]
      if plan_id
        if @plans.include?(plan_id)
          plan_no = @plans[plan_id][:plan_no]
        else
          raise OpenShift::AriaException.new "Invalid Billing Plan Id: #{plan_id}"
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
        raise OpenShift::AriaException.new "Invalid Billing Supplemental Plan name: #{supp_plan_name}"
      end
      @supp_plans[supp_plan_name][:plan_no]
    end
  end
end
