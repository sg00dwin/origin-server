require 'openshift/selenium_test_case'

require 'openshift/rest/pages'
require 'openshift/rest/forms'
require 'openshift/rest/navbars'

module OpenShift
  module Rest
    class TestCase < OpenShift::SeleniumTestCase
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
        # [email login, password, valid namespace]
        ["test#{data[:uid]}@redhat.com", data[:password], "test#{data[:uid]}"]
      end

      def dummy_ssh_key(type='ssh-rsa')
        "#{type} AAAA#{Time.now.to_f.to_s.sub('.', '/')}B3NzaC1kc3MAAACBAOmtY5dhWtrsoFFlc6hjhTcu7ZEV/V4iCixcpbMedboUfiWz2Fd6x2zLrsx432Dh7IDPz2/KwW5M+h7Ns0E7rLQvJbeB7NAXjKrgTPQiuKmhx+czDQmy5KdINtddHRR0TARpd5aSE6MHTIgav8+9bvM1h5s3S1g7khempam+0Wq/AAAAFQDrV0Jcs+YjxH5OMTAKJOzmEiyAswAAAIBsykXvxFzro6KtGn7gfeyfJSTvE7UtswYi2TqU8Hopbor0fAKKw2oKo3jJB4/fM0sm7s61i0YgLkv++tEDF1xUJnTVElZkRVIdhtNo1CnlOMkLoUnIaCubhbyDaV5oPMMHDx6QrCLz1rUFLwjGoZeuzoqXaY43aTG9dZiFZdB/SQAAAIEArHL0J93k6yz6/8/gfXKMqa1xk+i0F+9ARuw0VzHw3tn1EeVlvAXukS1ZnHriK+08kX3kI4ZQejdKyTAFu4UWLJacjg+jDj5qXeQLxrHE8tXrfLboszQriV5Pg9e2qjwSso4irXkptbomie1IcdlCA0lZC6auIAoLCKa3cILojKE="
      end

      def dummy_ssh_key2(prefix='BBBB')
        "ssh-rsa #{prefix}#{Time.now.to_f.to_s.sub('.', '/')}B3NzaC1kc3MAAACBAOmtY5dhWtrsoFFlc6hjhTcu7ZEV/V4iCixcpbMedboUfiWz2Fd6x2zLrsx432Dh7IDPz2/KwW5M+h7Ns0E7rLQvJbeB7NAXjKrgTPQiuKmhx+czDQmy5KdINtddHRR0TARpd5aSE6MHTIgav8+9bvM1h5s3S1g7khempam+0Wq/AAAAFQDrV0Jcs+YjxH5OMTAKJOzmEiyAswAAAIBsykXvxFzro6KtGn7gfeyfJSTvE7UtswYi2TqU8Hopbor0fAKKw2oKo3jJB4/fM0sm7s61i0YgLkv++tEDF1xUJnTVElZkRVIdhtNo1CnlOMkLoUnIaCubhbyDaV5oPMMHDx6QrCLz1rUFLwjGoZeuzoqXaY43aTG9dZiFZdB/SQAAAIEArHL0J93k6yz6/8/gfXKMqa1xk+i0F+9ARuw0VzHw3tn1EeVlvAXukS1ZnHriK+08kX3kI4ZQejdKyTAFu4UWLJacjg+jDj5qXeQLxrHE8tXrfLboszQriV5Pg9e2qjwSso4irXkptbomie1IcdlCA0lZC6auIAoLCKa3cILojKE="
      end
    end
  end
end
