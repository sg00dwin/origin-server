require 'csv'

class BillsController < ConsoleController
  include BillingAware
  include AsyncAware

  # trigger synchronous module load 
  [Aria, Aria::UserContext] if Rails.env.development?

  before_filter :authenticate_user!
  before_filter :user_can_upgrade_plan!
  
  before_filter :require_aria_account
  before_filter :require_invoices

  def index
    populate_view(@user, @invoices, @invoices.first)
  end

  def export
    @filename = "history"
    @transactions = @user.transactions
    @transaction_details = {}
    @transactions.select {|t| t.transaction_type == 1 }.each_slice(Rails.configuration.aria_max_parallel_requests) do |slice|
      slice.each do |t|
        async do
          @transaction_details[t.transaction_source_id] = Aria.cached.get_invoice_details(@user.acct_no, t.transaction_source_id)
        end
      end
      join!
    end

    respond_to do |format|
      format.csv do
        h = self.response.headers
        h["Content-Disposition"] = "attachment; filename=#{@filename}.csv"
        h["Content-Transfer-Encoding"] = "binary"
      end
    end
  end

  def locate
    if params[:id].present?
      redirect_to account_bill_path(params[:id])
    else
      redirect_to account_bills_path
    end
  end

  def show
    invoice = find_invoice(params[:id])
    populate_view(@user, @invoices, invoice)
  end

  def print
    invoice = find_invoice(params[:id])
    render :text => "#{invoice.statement_content} <script>try{window.print();}catch(e){}</script>" and return
  end


  protected
    def active_tab
      :account
    end

    def require_aria_account
      @user = current_aria_user
      redirect_to account_path and return false unless @user.has_account?
    end

    def require_invoices
      @invoices = @user.invoices_with_amounts
      render :no_bills and return false if @invoices.empty?
    end

    def find_invoice(id)
      invoice = @invoices.detect {|i| i.invoice_no.to_s == params[:id] }
      raise Aria::ResourceNotFound.new("Invoice ##{id} does not exist") if invoice.nil?
      invoice
    end

    def populate_view(user, invoices, invoice)
      @plan = current_api_user.plan

      @invoice_options = invoices.map {|i| [
        "#{i.bill_date.to_datetime.to_s(:billing_date)}",
        i.invoice_no.to_s
      ]}
      @id = invoice.invoice_no.to_s
      @bill = @user.bill_for(invoice)

      index = invoices.index(invoice)
      @next_no = invoices[index - 1].invoice_no if index and index > 0
      @prev_no = invoices[index + 1].invoice_no if index and index < invoices.length - 1

      @is_test_user = user.test_user?
      @virtual_time = Aria::DateTime.now if Aria::DateTime.virtual_time?

      @next_bill = user.next_bill
      if @next_bill
        current_usage_items = @next_bill.unbilled_usage_line_items
        past_usage_items = invoice.line_items.select(&:usage?)
        if current_usage_items.present? or past_usage_items.present?
          @usage_items = {
            "Next bill" => current_usage_items || [],
            "This bill" => past_usage_items || []
          }
        end
        @usage_types = Aria::UsageLineItem.type_info(@usage_items.values.flatten) if @usage_items
      end
    end
end
