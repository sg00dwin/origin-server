class ActiveSupport::TestCase
  def with_account_holder
    @@account_holder ||= begin
      WebUser.new({
        :email_address=> "account_holder@test1.com",
        :rhlogin=>       "account_holder@test1.com",
        :ticket => '1'
      }).tap do |u|
        u.extend(Aria::User)
        begin
          u.create_account
        rescue Aria::AccountExists
        end
        u.account_details
      end
    end
    set_user(@@account_holder.dup)
  end
end
