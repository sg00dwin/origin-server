require 'openshift/selenium_test_case'

require 'openshift/rest/pages'
require 'openshift/rest/forms'

class RestConsole < OpenShift::SeleniumTestCase

  def setup
    super
  end

  def test_create_namespace_blank
  end

  def test_create_namespace_invalid
  end

  def test_create_namespace_valid
    @login, pass = dummy_credentials
    create_namespace(@login, pass, @login)
  end

  def test_update_namespace
    @login, pass = dummy_credentials
    create_namespace(@login, pass, @login)

    @rest_account.find_edit_namespace_button.click
    wait_for_page @rest_account.domain_edit_page.path

    form = @rest_account.domain_form

    new_namespace = @login + "a"

    form.set_value(:namespace, new_namespace)
    assert form.get_value(:namespace) != @login

    form.submit

    wait_for_page @rest_account.path
    await("namespace updated on page") { text('.namespace') == new_namespace }
  end

def test_ssh_keys
    @login, pass = dummy_credentials

    signin(@login, pass)
    @rest_account.open

    create_namespace(@login, pass, @login, false)

    # go back to the account page
    @rest_account.open

    # create a default SSH key
    form = @rest_account.ssh_key_form

    key = dummy_ssh_key
    form.set_value(:key, key)
    form.submit

    await('preview SSH key') { @rest_account.find_ssh_key_row('default') }
    # we shorten key so split and check via regex
    cmp_key = @rest_account.find_ssh_key('default')
    cmp_key = cmp_key.split('..')
    if cmp_key.length > 1:
      key_re = "(#{Regexp.quote(cmp_key[0])}).*(#{Regexp.quote(cmp_key[1])})$"
      assert_match /#{key_re}/, key
    else
      assert_equal key, cmp_key[0]
    end
  end

  private

  # helper method for creating a namespace
  # post: user is on account page
  def create_namespace(login, password, namespace, log_in=true)
    if log_in
      signin(login, password)
    end

    @rest_account.open

    form = @rest_account.domain_form

    assert !form.in_error?(:namespace)

    form.set_value(:namespace, namespace)

    form.submit

    wait_for_page @rest_account.path

    await("namespace created") { text('.namespace') ==  namespace }
  end

  def dummy_credentials
    return ["test#{data[:uid]}", data[:password]]
  end

  def dummy_ssh_key(type='ssh-rsa')
    "#{type} AAAA#{Time.now.to_f.to_s.sub('.', '/')}B3NzaC1kc3MAAACBAOmtY5dhWtrsoFFlc6hjhTcu7ZEV/V4iCixcpbMedboUfiWz2Fd6x2zLrsx432Dh7IDPz2/KwW5M+h7Ns0E7rLQvJbeB7NAXjKrgTPQiuKmhx+czDQmy5KdINtddHRR0TARpd5aSE6MHTIgav8+9bvM1h5s3S1g7khempam+0Wq/AAAAFQDrV0Jcs+YjxH5OMTAKJOzmEiyAswAAAIBsykXvxFzro6KtGn7gfeyfJSTvE7UtswYi2TqU8Hopbor0fAKKw2oKo3jJB4/fM0sm7s61i0YgLkv++tEDF1xUJnTVElZkRVIdhtNo1CnlOMkLoUnIaCubhbyDaV5oPMMHDx6QrCLz1rUFLwjGoZeuzoqXaY43aTG9dZiFZdB/SQAAAIEArHL0J93k6yz6/8/gfXKMqa1xk+i0F+9ARuw0VzHw3tn1EeVlvAXukS1ZnHriK+08kX3kI4ZQejdKyTAFu4UWLJacjg+jDj5qXeQLxrHE8tXrfLboszQriV5Pg9e2qjwSso4irXkptbomie1IcdlCA0lZC6auIAoLCKa3cILojKE="
  end
end
