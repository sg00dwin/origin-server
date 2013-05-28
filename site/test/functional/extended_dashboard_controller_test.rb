require File.expand_path('../../test_helper', __FILE__)

class ExtendedDashboardControllerTest < ActionController::TestCase
  tests AccountController

  def setup
    @controller.stubs(:skip_captcha?).returns(true)
  end

  def stub_aria_checks
    Aria.expects(:gen_random_string).at_least(0).returns("123")
    Aria::UserContext.any_instance.expects(:create_account).at_least(0).raises(Aria::AccountExists.new)
    Aria::UserContext.any_instance.expects(:acct_no).at_least(0).returns(123)
    Aria::UserContext.any_instance.expects(:currency_cd).at_least(0).returns('usd')
    Aria::UserContext.any_instance.expects(:account_details).at_least(0).returns(Aria::WDDX::Struct.new({}))
  end

  define_method :cache_clear do
  end

  if Rails.configuration.aria_enabled

    [:silver, :downgrading, :free].each do |plan|
      [:normal, :terminated, :suspended, :dunning, :cancelled, :cancellation_pending].each do |status|
        [:good, :bad, :missing].each do |payment|
          [:paid, :unpaid, :none].each do |last_bill|
            [:none, :paid, :free, :'paid_historical', :'free_historical'].each do |usage|

              test "should render dashboard with #{plan} plan #{status} status #{payment} payment #{last_bill} last bill #{usage} usage" do
                
                with_account_holder

                params = {
                  :debug => 1,
                  :plan => plan,
                  :status => status,
                  :payment => payment,
                  :last_bill => last_bill,
                  :usage => usage
                }
                
                get :show, params

                assert_response :success
                assert_template :show
                assert assigns(:user)
                assert assigns(:plan)
                assert assigns(:account_status)
                assert_select 'h1', /My Account/, response.inspect
              end
            end
          end
        end
      end
    end

  end
end
