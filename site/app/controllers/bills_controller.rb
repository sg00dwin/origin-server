class BillsController < ConsoleController
  include BillingAware

  before_filter :authenticate_user!

  def index
    user = Aria::UserContext.new(current_user)

    @user = current_api_user
    @plan = @user.plan

    redirect_to account_path unless user.has_account?

    @is_test_user = user.test_user?

    invoices = user.invoices_with_amounts
    render :no_bills and return if invoices.empty?

    invoice_no = params[:invoice_no] || invoices.first.invoice_no.to_s
    invoice = invoices.detect {|i| i.invoice_no.to_s == invoice_no }

    if invoice and params[:print]
      render :text => "#{invoice.statement_content} <script>try{window.print();}catch(e){}</script>" and return
    end

    @invoice_options = invoices.map {|i| [ "#{i.bill_date.to_datetime.to_s(:billing_date)}", i.invoice_no.to_s ] }
    @invoice_no = invoice_no
    @bill = user.bill_for(invoice)

    index = invoices.index(invoice)
    @next_no = invoices[index - 1].invoice_no if index and index > 0
    @prev_no = invoices[index + 1].invoice_no if index and index < invoices.length - 1

    if @bill
      @next_bill = user.next_bill
      current_usage_items = @next_bill.unbilled_usage_line_items
      past_usage_items = invoice.line_items.select(&:usage?)
      if current_usage_items.present? and past_usage_items.present?
        @usage_items = {
          "Current" => current_usage_items,
          "This bill" => past_usage_items
        }
      else
        # TODO: remove, debug
        # @usage_items = {
        #   "Current" => current_usage_items
        # }.merge(
        #   {
        #     "This bill" => [
        #       OpenStruct.new({:units_label => 'hour', :units => 10, :total_cost => 1, :name => "Gear: Small"}),
        #       OpenStruct.new({:units_label => 'hour', :units => 10, :total_cost => 3, :name => "Gear: Medium"})
        #     ]
        #   }
        # )
      end
      @usage_types = Aria::UsageLineItem.type_info(@usage_items.values.flatten) if @usage_items
    end

  end
end
