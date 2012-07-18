module Aria
  module Methods

    # Helper methods that force certain arguments on Aria methods and
    # unwrap output.  These methods should not catch exceptions or
    # perform complicated logic - they only exist to enforce certain 
    # call behaviors.

    def available?(message='Aria is not available:')
      Aria.gen_random_string
      true
    rescue Aria::AuthenticationError, Aria::NotAvailable => e
      puts "#{message} (#{caller.find{ |s| not s =~ /\/lib\/aria[\.\/]/}}) #{e}"
      false
    end

    def client_no
      Rails.application.config.aria_client_no
    end

    def default_plan_no
      Rails.application.config.aria_default_plan_no
    end

    def set_session(*args)
      super.session_id
    end

    def userid_exists(user_id)
      super(:user_id => user_id)
    end

    def get_client_plans_basic
      super.plans_basic
    end

    def get_acct_no_from_user_id(user_id)
      super(:user_id => user_id).acct_no
    end

    def create_acct_complete(params)
      p = encode_supplemental(params)
      Rails.logger.debug "create_acct_complete #{p.inspect}"
      super p
    end

    def update_acct_complete(acct_no, params)
      params[:acct_no] = acct_no
      p = encode_supplemental(params, true)
      Rails.logger.debug "create_acct_complete #{p.inspect}"
      super p
    end

    def get_acct_details_all(acct_no)
      super(:acct_no => acct_no)
    end
    def get_supp_field_values(acct_no, field_name)
      super(:acct_no => acct_no, :field_name => field_name).supp_field_values || []
    end

    def set_reg_uss_config_params(set, *args)
      opts = args.extract_options!
      if args.length == 2
        super(:set_name => set, :param_name => args[0], :param_val => args[1])
      else
        names = []
        values = []
        opts.each_pair do |k,v|
          set_reg_uss_config_params(set, k, v) and next if k.to_s.include? '|' or v.to_s.include? '|'
          names << k
          values << v
        end
        super(:set_name => set, :param_name => names.join('|'), :param_val => values.join('|'))
      end
    end

    private
      def encode_supplemental(params, update=false)
        if supplemental = params.delete(:supplemental)
          names, values = [], []
          supplemental.each_pair do |k,v|
            next if k.nil? || v.nil?
            names << k.to_s.gsub(/\|/,'_')
            values << v.to_s.gsub(/\|/,'_')
          end
          params[:supp_field_names] = names.join('|')
          params[:supp_field_values] = values.join('|')
          params[:supp_field_directives] = ([2] * values.length).join('|') if update
        end
        params
      end
 end
end
