class BillsController < ConsoleController
  include BillingAware

  before_filter :authenticate_user!

  def index
    user = Aria::UserContext.new(current_user)

    @user = current_api_user
    @plan = @user.plan

    unless user.has_account? and user.bill_dates.present?
      # TODO: show no billing info page
    end

    unless user.account_details.is_test_acct == 'N'
      # TODO: show test user error
    end

    @bill_dates = user.bill_dates
    @bill_date = params[:date] || @bill_dates.first
    @bill = user.bill_for(@bill_date)

    index = @bill_dates.index(@bill_date)
    @next_date = @bill_dates[index - 1] if index and index > 0
    @prev_date = @bill_dates[index + 1] if index and index < @bill_dates.length - 1
  end
end
