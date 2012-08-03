require 'fileutils'

$metrics_proc_regex = /httpd -C Include .*metrics/

# Pulls the reverse proxy destination from the proxy conf file and ensures
# the path it forwards to is accessible via the external IP of the instance.
Then /^the metrics web console url will be accessible$/ do
  conf_file_name = "#{@gear.uuid}_#{@account.domain}_#{@app.name}/metrics-0.1.conf"
  conf_file_path = "#{$libra_httpd_conf_d}/#{conf_file_name}"

  # The URL segment for the cart lives in the proxy conf
  cart_path = `/bin/awk '/ProxyPassReverse/ {printf "%s", $2;}' #{conf_file_path}`

  # Assemble a test URL for the cart. This seems pretty cheesy. I could query the root,
  # but we'll get a 302 redirect, and I'm not sure if that's a good test.
  status_url = "https://127.0.0.1/server-status?auto"

  # Strip just the status code out of the response. Set the Host header to 
  # simulate an external request, exercising the front-end httpd proxy.
  res = `/usr/bin/curl -k -w %{http_code} -s -o /dev/null -H 'Host: #{@app.name}-#{@account.domain}.dev.rhcloud.com' #{status_url}`

  raise "Expected 200 response from #{status_url}, got #{res}" unless res == "200"
end
