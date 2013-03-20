class BillsController < ConsoleController
  include BillingAware

  before_filter :authenticate_user!
  before_filter :require_aria_account
  before_filter :require_invoices

  def index
    populate_view(@user, @invoices, @invoices.first)
  end

  def export
    render :text => "Export" and return
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
    def require_aria_account
      @user = Aria::UserContext.new(current_user)
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
      @invoice_options = invoices.map {|i| [
        "#{i.bill_date.to_datetime.to_s(:billing_date)}",
        i.invoice_no.to_s,
        {"data-url" => account_bill_path(i.invoice_no)}
      ]}
      @id = invoice.invoice_no.to_s
      @bill = @user.bill_for(invoice)

      index = invoices.index(invoice)
      @next_no = invoices[index - 1].invoice_no if index and index > 0
      @prev_no = invoices[index + 1].invoice_no if index and index < invoices.length - 1

      @is_test_user = user.test_user?

      @next_bill = user.next_bill
      current_usage_items = @next_bill.unbilled_usage_line_items
      past_usage_items = invoice.line_items.select(&:usage?)
      if current_usage_items.present? and past_usage_items.present?
        @usage_items = {
          "Current" => current_usage_items,
          "This bill" => past_usage_items
        }
      end
      @usage_types = Aria::UsageLineItem.type_info(@usage_items.values.flatten) if @usage_items
    end
end
