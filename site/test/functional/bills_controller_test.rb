# encoding: UTF-8

require File.expand_path('../../test_helper', __FILE__)

class BillsControllerTest < ActionController::TestCase

  with_clean_cache
  
  setup { Aria.expects(:gen_random_string).at_least(0).returns("123") }

  def plan
    Aria::WDDX::Struct.new({
      'plan_no' => 1,
      'plan_name' => 'Silver',
      'plan_desc' =>  'Go large with the Silver plan\n\nFeatures:\n* Price: $42/Month *\n* Free Gears: 3\n* Support: By Red Hat *\n* Scaling: 3 Included *\n* Additional Storage: $1/GB per month *\n* SSL: For custom domains *\n* Java EE6 Full Profile & CDI: 3 gears free; $0.03/hr per additional gear *'
    })
  end
  def with_user(user)
    @user ||= begin
      @controller.expects(:current_user).at_least_once.returns(user)
      set_user(user)
    end
  end
  def simple
    WebUser.new :rhlogin => 'outside_user@gmail.com', :email_address => 'outside_user@gmail.com', :streamline_type => :full
  end
  def full(acct_details={})
    Aria::MasterPlan.any_instance.expects(:aria_plan).at_least(0).returns(plan)
    Aria::DateTime.expects(:virtual_time?).at_least(0).returns(false)
    Aria.expects(:get_acct_no_from_user_id).at_least(0).returns(123)
    Aria.expects(:get_acct_details_all).at_least(0).returns(Aria::WDDX::Struct.new({
      'currency_cd' => 'usd',
      'userid' => '123',
      'is_test_acct' => 'N',
      'bill_day' => '1',
      'status_cd' => '1',
      'plan_no' => '1',
      'plan_name' => 'Silver',
      'balance' => '0'
    }.merge(acct_details)))
    Aria.expects(:get_acct_trans_history).at_least(0).returns([])
    Aria.expects(:get_client_plans_all).at_least(0).returns([])

    WebUser.new :rhlogin => 'rhnuser', :email_address => 'rhnuser@redhat.com', :streamline_type => :full
  end

  test "should redirect if aria is not enabled" do
    with_config(:aria_enabled, false) do
      user = with_user(simple)

      get :index
      assert_redirected_to account_path

      get :show, :id => 1
      assert_redirected_to account_path

      get :export
      assert_redirected_to account_path

      get :print, :id => 1
      assert_redirected_to account_path

      get :locate
      assert_redirected_to account_path
    end
  end

  test "should show an empty page when the user has no bills" do
    omit_if_aria_is_unavailable

    user = with_user(full)
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns([])
    get :index
    assert_not_nil assigns[:user]
    assert_template :no_bills

    get :show
    assert_not_nil assigns[:user]
    assert_template :no_bills

    get :export
    assert_not_nil assigns[:user]
    assert_template :no_bills

    get :print
    assert_not_nil assigns[:user]
    assert_template :no_bills    

    get :locate
    assert_not_nil assigns[:user]
    assert_template :no_bills
  end

  test "should show an empty page when the user has only empty invoices" do
    omit_if_aria_is_unavailable

    user = with_user(full)
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns([
      stub_invoice({'invoice_no' => 2, 'date' => '2010-02-01', 'debit' => 0, 'credit' => 0}),
      stub_invoice({'invoice_no' => 1, 'date' => '2010-01-01', 'debit' => 0, 'credit' => 0})
    ])
    get :index
    assert_not_nil assigns[:user]
    assert_template :no_bills

    get :show
    assert_not_nil assigns[:user]
    assert_template :no_bills

    get :export
    assert_not_nil assigns[:user]
    assert_template :no_bills

    get :print
    assert_not_nil assigns[:user]
    assert_template :no_bills    

    get :locate
    assert_not_nil assigns[:user]
    assert_template :no_bills
  end  

  test "should display bills page for a single invoice" do
    omit_if_aria_is_unavailable

    user = with_user(full)

    invoice = stub_invoice
    invoice.expects(:line_items).at_least_once.returns([])
    invoice.expects(:payments).at_least_once.returns([])
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns([ invoice ])
    Aria::UserContext.any_instance.expects(:next_bill).at_least_once.returns(false)

    get :index
    assert_not_nil assigns[:user]
    assert_not_nil assigns[:bill]
    assert_nil assigns[:next_no]
    assert_nil assigns[:prev_no]
    assert_template :index
    assert_select "select#id", false
    assert_select "a.previous-link", false
    assert_select "a.next-link", false

    get :show, :id => invoice.invoice_no
    assert_not_nil assigns[:user]
    assert_not_nil assigns[:bill]
    assert_nil assigns[:next_no]
    assert_nil assigns[:prev_no]
    assert_template :show
    assert_select "select#id", false
    assert_select "a.previous-link", false
    assert_select "a.next-link", false
  end  

  test "should display bills page for an invoice with previous invoices" do
    omit_if_aria_is_unavailable

    user = with_user(full)

    invoices = [
      stub_invoice({'invoice_no' => 3, 'date' => '2010-03-01'}),
      stub_invoice({'invoice_no' => 2, 'date' => '2010-02-01'}),
      stub_invoice({'invoice_no' => 1, 'date' => '2010-01-01'})
    ]
    invoices.first.expects(:line_items).at_least_once.returns([])
    invoices.first.expects(:payments).at_least_once.returns([])
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns(invoices)
    Aria::UserContext.any_instance.expects(:next_bill).at_least_once.returns(false)

    get :index
    assert_not_nil assigns[:user]
    assert_not_nil assigns[:bill]
    assert_nil assigns[:next_no]
    assert assigns[:prev_no]
    assert_equal 2, assigns[:prev_no]
    assert_template :index
    assert_select "select#id"
    assert_select "select#id option[selected][value=3]"
    assert_select "a.previous-link"
    assert_select "a.next-link", false

    get :show, :id => 3
    assert_not_nil assigns[:user]
    assert_not_nil assigns[:bill]
    assert_nil assigns[:next_no]
    assert assigns[:prev_no]
    assert_equal 2, assigns[:prev_no]
    assert_template :bill
    assert_select "select#id"
    assert_select "select#id option[selected][value=3]"
    assert_select "a.previous-link"
    assert_select "a.next-link", false
  end  

  test "should display bills page for an invoice with later invoices" do
    omit_if_aria_is_unavailable

    user = with_user(full)

    invoices = [
      stub_invoice({'invoice_no' => 3, 'date' => '2010-03-01'}),
      stub_invoice({'invoice_no' => 2, 'date' => '2010-02-01'}),
      stub_invoice({'invoice_no' => 1, 'date' => '2010-01-01'})
    ]
    invoices.last.expects(:line_items).at_least_once.returns([])
    invoices.last.expects(:payments).at_least_once.returns([])
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns(invoices)
    Aria::UserContext.any_instance.expects(:next_bill).at_least_once.returns(false)

    get :show, :id => 1
    assert_not_nil assigns[:user]
    assert_not_nil assigns[:bill]
    assert assigns[:next_no]
    assert_equal 2, assigns[:next_no]
    assert_nil assigns[:prev_no]
    assert_template :bill
    assert_select "select#id"
    assert_select "select#id option[selected][value=1]"
    assert_select "a.previous-link", false
    assert_select "a.next-link"
  end  

  test "should display error page for missing invoice" do
    omit_if_aria_is_unavailable

    user = with_user(full)

    invoices = [
      stub_invoice({'invoice_no' => 3, 'date' => '2010-03-01'}),
      stub_invoice({'invoice_no' => 2, 'date' => '2010-02-01'}),
      stub_invoice({'invoice_no' => 1, 'date' => '2010-01-01'})
    ]
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns(invoices)

    get :show, :id => 9
    assert_template :not_found
    assert_select "h1", "Invoice #9 does not exist"

    get :print, :id => 9
    assert_template :not_found
    assert_select "h1", "Invoice #9 does not exist"    
  end

  [
    ["usd","$"], 
    ["cad", "C$"], 
    ["eur", "€ "]
  ].each do |(currency_cd, currency_symbol)|
    [true, false].each do |show_rates|
      test "should compare usage between bill and current period in #{currency_cd} #{show_rates ? 'with' : 'without'} current rates" do
        with_config(:aria_show_unbilled_usage_rates, show_rates) do
          do_usage_test(currency_cd, currency_symbol)
        end
      end
    end

    test "should show forwarded balance based on statements in #{currency_cd}" do
      do_forwarded_balance_test(currency_cd, currency_symbol)
    end

    test "should export invoice successfully in #{currency_cd}" do
      do_export_test(currency_cd, currency_symbol)
    end
  end

  test "should show different title for bill without payments" do
    omit_if_aria_is_unavailable
    # TODO: Not "You were charged $X"
  end

  test "should redirect to show invoice" do
    omit_if_aria_is_unavailable

    user = with_user(full)
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns([stub_invoice])

    post :locate
    assert_redirected_to account_bills_path

    post :locate, :id => 123
    assert_redirected_to account_bill_path(123)
  end

  test "should echo content from aria" do
    omit_if_aria_is_unavailable

    user = with_user(full)
    invoice = stub_invoice
    invoice.expects(:statement_content).returns("<h1>Content from Aria</h1>")
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns([invoice])

    get :print, :id => invoice.invoice_no
    assert_response :success
    assert_select "h1", "Content from Aria"
    assert_select "script:content(?)", /window.print/
  end

  test "should handle print error from aria" do
    omit_if_aria_is_unavailable

    user = with_user(full)
    invoice = stub_invoice
    invoice.expects(:statement_content).raises(Aria::NotAvailable.new(response))
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns([invoice])

    get :print, :id => invoice.invoice_no
    assert_template :error
  end

  private

  def do_usage_test(currency_cd, currency_symbol)
    omit_if_aria_is_unavailable

    user = with_user(full({'currency_cd' => currency_cd}))

    invoices = [
      stub_invoice({'invoice_no' => 3, 'date' => '2010-03-01'}),
      stub_invoice({'invoice_no' => 2, 'date' => '2010-02-01'}),
      stub_invoice({'invoice_no' => 1, 'date' => '2010-01-01'})
    ]
    invoices.first.expects(:line_items).at_least_once.returns([
      Aria::UsageLineItem.new({'usage_type_description' => 'Small Gear', 'units' => 1.00, 'rate_per_unit' => 1.0}, 1),
      Aria::UsageLineItem.new({'usage_type_description' => 'Small Gear', 'units' => 0.10, 'rate_per_unit' => 1.0}, 1),
      Aria::UsageLineItem.new({'usage_type_description' => 'Small Gear', 'units' => 0.01, 'rate_per_unit' => 1.0}, 1)
    ])
    invoices.first.expects(:payments).at_least_once.returns([])
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns(invoices)
    Aria::UserContext.any_instance.expects(:next_bill).at_least_once.returns(
      Aria::Bill.new(
        :start_date => Date.today, 
        :end_date => Date.today, 
        :due_date => Date.today, 
        :day => 1, 
        :unbilled_usage_line_items => [
          Aria::UsageLineItem.new({'usage_type_description' => 'Medium Gear', 'units' => 2.00, 'rate_per_unit' => 2.0}, 1),
          Aria::UsageLineItem.new({'usage_type_description' => 'Medium Gear', 'units' => 0.20, 'rate_per_unit' => 2.0}, 1),
          Aria::UsageLineItem.new({'usage_type_description' => 'Medium Gear', 'units' => 0.02, 'rate_per_unit' => 2.0}, 1)
        ])
    )

    get :show, :id => 3
    assert usage_items = assigns[:usage_items]
    assert usage_types = assigns[:usage_types]
    assert_template :show
    assert_select "h2", "Compare Usage"

    if Rails.configuration.aria_show_unbilled_usage_rates
      assert_select "table.usage-charges" do
        assert_select "caption", :text => "Usage Charges"
        assert_select "tbody tr", 2 do |tr|
          assert_select tr[0], 'td:content(?)', 'Next bill'
          assert_select tr[0], 'div.graph-element.type-2[style*="100%"]'
          assert_select tr[0], 'td:content(?)', "#{currency_symbol}4.44"

          assert_select tr[1], 'td:content(?)', 'This bill'
          assert_select tr[1], 'div.graph-element.type-1[style*="25%"]'
          assert_select tr[1], 'td:content(?)', "#{currency_symbol}1.11"
        end
      end
    else
      assert_select "table.usage-charges", :count => 0
    end

    assert_select "table.usage-type-1" do
      assert_select "caption", :text => "Gear: Small"
      assert_select "tbody tr", 2 do |tr|
        assert_select tr[0], 'td:content(?)', 'Next bill'
        assert_select tr[0], 'div.graph-element.type-1[style*="0%"]'
        assert_select tr[0], 'td:content(?)', '0.0 gear-hours'

        assert_select tr[1], 'td:content(?)', 'This bill'
        assert_select tr[1], 'div.graph-element.type-1[style*="100%"]'
        assert_select tr[1], 'td:content(?)', '1.1 gear-hours'
      end
    end

    assert_select "table.usage-type-2" do
      assert_select "caption", :text => "Gear: Medium"
      assert_select "tbody tr", 2 do |tr|
        assert_select tr[0], 'td:content(?)', 'Next bill'
        assert_select tr[0], 'div.graph-element.type-2[style*="100%"]'
        assert_select tr[0], 'td:content(?)', '2.2 gear-hours'

        assert_select tr[1], 'td:content(?)', 'This bill'
        assert_select tr[1], 'div.graph-element.type-2[style*="0%"]'
        assert_select tr[1], 'td:content(?)', '0.0 gear-hours'
      end
    end
  end

  def do_forwarded_balance_test(currency_cd, currency_symbol)
    omit_if_aria_is_unavailable

    user = with_user(full({'currency_cd' => currency_cd}))

    invoices = [
      stub_invoice({'invoice_no' => 3, 'date' => '2010-03-01', 'paid_date' => nil, 'debit' => 100, 'credit' => 200}),
      stub_invoice({'invoice_no' => 2, 'date' => '2010-02-01', 'paid_date' => nil, 'debit' => 100, 'credit' => 100}),
      stub_invoice({'invoice_no' => 1, 'date' => '2010-01-01'})
    ]
    Aria::Invoice.any_instance.expects(:line_items).at_least_once.returns([])
    Aria::Invoice.any_instance.expects(:payments).at_least_once.returns([])
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns(invoices)
    Aria::UserContext.any_instance.expects(:next_bill).at_least_once.returns(false)

    Aria.expects(:get_acct_trans_history).at_least_once.returns([
      stub_invoice_transaction({"transaction_source_id"=>3, "statement_no" => 33}),
      stub_invoice_transaction({"transaction_source_id"=>2, "statement_no" => 22}),
      stub_invoice_transaction({"transaction_source_id"=>1, "statement_no" => 11})
    ])
    Aria.expects(:get_acct_statement_history).at_least_once.returns([
      Aria::WDDX::Struct.new({"statement_no" => 33, "balance_forward_amount" => 333}),
      Aria::WDDX::Struct.new({"statement_no" => 22, "balance_forward_amount" => 0})
    ])

    # Statement with balance
    get :show, :id => 3
    assert_template :show
    assert_select "td:content(?)", "Forwarded balance"
    assert_select "td:content(?)", "#{currency_symbol}333.00"

    # Statement without balance
    get :show, :id => 2
    assert_template :show
    assert_select "td:content(?)", "Forwarded balance", false
    assert_select "td:content(?)", "#{currency_symbol}0.00", false

    # No statement
    get :show, :id => 1
    assert_template :show
    assert_select "td:content(?)", "Forwarded balance", false
    assert_select "td:content(?)", "#{currency_symbol}0.00", false    
  end

  def do_export_test(currency_cd, currency_symbol)
    omit_if_aria_is_unavailable

    user = with_user(full({'currency_cd' => currency_cd}))
    invoice = stub_invoice
    Aria::UserContext.any_instance.expects(:invoices).at_least_once.returns([invoice])
    Aria::UserContext.any_instance.expects(:transactions).at_least_once.returns([
      stub_payment_transaction,
      stub_invoice_transaction
    ])
    Aria.expects(:get_invoice_details).at_least_once.returns([
      Aria::WDDX::Struct.new({"line_no"=>1, "service_no"=>1, "service_name"=>"Plan: Silver",     "units"=>1,"rate_per_unit"=>1,   "amount"=>1,    "description"=>"Plan: Silver",                "date_range_start"=>'2010-01-01',"date_range_end"=>'2010-01-31',"usage_type_no"=>nil,"plan_no"=>1,  "plan_name"=>'Silver'}),
      Aria::WDDX::Struct.new({"line_no"=>2, "service_no"=>2, "service_name"=>"Gear: Small",      "units"=>1,"rate_per_unit"=>1.23,"amount"=>1.23, "description"=>"Small Gear (1 hour @ #{currency_symbol}1.23)", "date_range_start"=>'2010-01-01',"date_range_end"=>'2010-01-31',"usage_type_no"=>123,"plan_no"=>1,  "plan_name"=>'Silver'}),
      Aria::WDDX::Struct.new({"line_no"=>3, "service_no"=>3, "service_name"=>"State Sales Taxes","units"=>1,"rate_per_unit"=>nil, "amount"=>16.38,"description"=>"State Sales Taxes",           "date_range_start"=>nil,         "date_range_end"=>nil,         "usage_type_no"=>nil,"plan_no"=>nil,"plan_name"=>nil})
    ])

    get :export, :format => "csv"

    # Have to fetch body to trigger streaming generation
    assert body = response.body

    assert_response :success
    assert_equal 'text/csv; charset=utf-8', response.headers['Content-Type']

    assert_equal body, <<-eos
Transaction Date,Transaction ID,Transaction Description,Description,Date Range Start,Date Range End,Units,Rate,Amount
2010-01-01,543,Electronic Payment #321,,,,,,-#{currency_symbol}100.00

2010-01-01,345,Invoice #123,Plan: Silver,2010-01-01,2010-01-31,1,#{currency_symbol}1.00,#{currency_symbol}1.00
2010-01-01,345,Invoice #123,Gear: Small,2010-01-01,2010-01-31,1,#{currency_symbol}1.23,#{currency_symbol}1.23
2010-01-01,345,Invoice #123,State Sales Taxes,,,1,,#{currency_symbol}16.38

    eos
  end

  def stub_invoice(opts = {}, acct_no=123)
    date = opts['date'] || '2010-01-01'
    defaults = {
      'invoice_no'          => 1,
      'master_plan_no'      => 1,
      'master_plan_name'    => 'Silver',
      'currency_cd'         => 'usd',
      'bill_date'           => date,
      'paid_date'           => date,
      'debit'               => 100,
      'credit'              => 100,
      'recurring_bill_from' => date,
      'recurring_bill_thru' => (date.to_date + 1.month - 1.day).to_s,
      'usage_bill_from'     => nil,
      'usage_bill_thru'     => nil,
      'is_voided_ind'       => 0
    }

    Aria::Invoice.new(Aria::WDDX::Struct.new(defaults.merge(opts)), acct_no)
  end

  def stub_payment_transaction(opts = {})
    defaults = {
      "transaction_id"=>321,
      "transaction_type"=>3,
      "transaction_desc"=>"Electronic Payment #321",
      "transaction_amount"=>-100,
      "transaction_applied_amount"=>100,
      "transaction_currency"=>"usd",
      "transaction_create_date"=>"2010-01-01",
      "transaction_void_date"=>nil,
      "statement_no"=>432,
      "transaction_void_reason"=>nil,
      "client_receipt_id"=>nil,
      "transaction_comments"=>nil,
      "transaction_source_id"=>543,
      "transaction_ref_code"=>nil
    }
    Aria::WDDX::Struct.new(defaults.merge(opts))
  end

  def stub_invoice_transaction(opts = {})
    defaults = {
      "transaction_id"=>123,
      "transaction_type"=>1,
      "transaction_desc"=>"Invoice #123",
      "transaction_amount"=>100,
      "transaction_applied_amount"=>nil,
      "transaction_currency"=>"usd",
      "transaction_create_date"=>"2010-01-01",
      "transaction_void_date"=>nil,
      "statement_no"=>234,
      "transaction_void_reason"=>nil,
      "client_receipt_id"=>nil,
      "transaction_comments"=>nil,
      "transaction_source_id"=>345,
      "transaction_ref_code"=>nil
    }
    Aria::WDDX::Struct.new(defaults.merge(opts))
  end
end
