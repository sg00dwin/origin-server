module OpenShift
  class AriaEvent

    EVENTS = {
      "105" => "Account Status Changed",
      "106" => "Account Status Queued for Change",
      "118" => "Account Supplemental Field Value Added",
      "119" => "Account Supplemental Field Value Modified"
    }
    PLAN_STATE_UPDATE_RETRIES = 3
    PLAN_STATE_UPDATE_RETRY_TIME = 3
    ENTITLEMENTS = { :assign => "ASSIGN", :revoke => "REVOKE" }

    def self.handle_event(h)
      aria_config = Rails.application.config.billing[:config]
      h['event_id'].each do |ev|
        case ev.to_i
        when 105, 106
          # "-1" => "Suspended", "-2" => "Cancelled", "-3" => "Terminated"
          if h['status_cd'] < "0"
            mark_acct_canceled(h)
            h['apply_end_of_month'] = true if ev.to_i == 106
            send_entitlements(h, OpenShift::AriaEvent::ENTITLEMENTS[:revoke])
          end
        when 118, 119
          supp_field_info = get_supplemental_fields(h)
          if supp_field_info
            subject = "Openshift Notification - Account Info Modified"
            body = populate_contact_info(h, supp_field_info)
            email_to = aria_config[:event_peoples_team_email]
            OpenShift::AriaNotification.report_event(subject, body, email_to)
          end
        else
          Rails.logger.error "Invalid Event, id: #{ev}"
        end
      end
    end
   
    def self.send_entitlements(h, entitlement)
      billing_config = Rails.application.config.billing
      aria_config = billing_config[:config]
      aria_plans = billing_config[:plans]
      default_plan = billing_config[:default_plan]

      if h['plan_name'] and (aria_plans[default_plan][:name] != h['plan_name'])
        if entitlement == OpenShift::AriaEvent::ENTITLEMENTS[:assign]
          subject = "Openshift Notification - Assign Entitlements"
        elsif entitlement == OpenShift::AriaEvent::ENTITLEMENTS[:revoke]
          subject = "Openshift Notification - Revoke Entitlements"
        else
          raise Exception.new "Invalid Entitlement - #{entitlement}"
        end
        body = populate_plan_info(h)
        email_to = aria_config[:event_orders_team_email]
        OpenShift::AriaNotification.report_event(subject, body, email_to)
      end
    end

    private

    def self.get_login(h)
      login = ""
      begin
        user = CloudUser.find_by(usage_account_id: h['acct_no'])
        login = user.login if user
      rescue
        #Ignore
      end
      login
    end

    def self.get_account_data(h, base_info=false)
      login = h['login'] || get_login(h)
      effective = h['apply_end_of_month'] ? "End of Month" : "Immediate"
      tid = h['transaction_id'] ? "Aria PO#: #{h['transaction_id']}\n" : ""
      base_data = <<MSG
Account Data
-----------------------------------
RHLogin: #{login}
Aria Client#: #{h['acct_no']}
MSG
      if base_info
        data = ""
      else
        data = <<MSG

Sku: #{h['plan_name']}
Qty: #{h['plan_units']}
Effective: #{effective}
Promo Code: #{h['promo_code']}
MSG
      end
      base_data + tid + data
    end

    def self.get_account_contact(h)
      login = h['login'] || get_login(h)
      user_info = nil
      auth_service = OpenShift::AuthService.instance
      if auth_service.respond_to?('get_user_info')
        user_info = auth_service.get_user_info(login)
      end
      return if user_info.nil? or user_info.empty?
      data = <<MSG
End User Contact
-----------------------------------
First Name: #{user_info['firstName']}
Last Name: #{user_info['lastName']}
Company Name: #{user_info['company']}
Address1: #{user_info['address1']}
Address2: #{user_info['address2']}
City: #{user_info['city']}
State/Province: #{user_info['state']}
Postal Code: #{user_info['postalCode']}
Country: #{user_info['country']}
Phone: #{user_info['phoneNumber']}
Email: #{user_info['emailAddress']}
MSG
    end

    def self.get_billing_data
      data = <<MSG
Billing Data
-----------------------------------
Company Name: Aria Systems
MSG
    end

    def self.get_supplemental_fields(h)
      supp_fields = ""
      begin
        for i in 0..h['supp_field_name'].length-1 do
          next if h['supp_field_name'][i] == 'RHLogin'  # skip RHLogin, already listed in Account Data section
          supp_fields += "#{h['supp_field_name'][i]}: #{h['supp_field_value'][i]}\n"
        end 
      rescue
        # Ignore
      end  
      return if supp_fields.empty?
      data = <<MSG
Supplemental Fields
-----------------------------------
#{supp_fields}
MSG
    end

    def self.populate_contact_info(h, supp_field_info)
      body = <<MSG
#{get_account_data(h, true)}
#{get_account_contact(h)}
#{supp_field_info}
MSG
    end
   
    def self.populate_plan_info(h)
      supp_field_info = get_supplemental_fields(h)
      body = <<MSG
#{get_account_data(h)}
#{get_account_contact(h)}
MSG
      body + supp_field_info.to_s + get_billing_data
    end

    def self.mark_acct_canceled(h)
      begin
        login = h['login'] || get_login(h)
        Rails.logger.error "Unable to find 'RHLogin' field for the event: #{h}" if login.empty?
        filter = {:login => login, :pending_plan_id => nil, :pending_plan_uptime => nil}
        update = {"$set" => {:pending_plan_id => :free, :pending_plan_uptime => Time.now.utc, :plan_state => CloudUser::PLAN_STATES['canceled']}}
        user = nil
        OpenShift::AriaEvent::PLAN_STATE_UPDATE_RETRIES.times do 
          user = CloudUser.with(consistency: :strong).where(filter).find_and_modify(update, {:new => true})
          break if user
          sleep OpenShift::AriaEvent::PLAN_STATE_UPDATE_RETRY_TIME
        end
        Rails.logger.error "Failed to change plan state to 'canceled' for user '#{login}'. Event: #{h}" unless user
      rescue Exception => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.inspect
      end 
    end
  end
end
