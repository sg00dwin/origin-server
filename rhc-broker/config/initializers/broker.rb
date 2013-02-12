ApplicationObserver.instance
CloudUserObserver.instance
DomainObserver.instance
BillingObserver.instance
#customizations to models
require 'cloud_user_ext'
require 'usage_ext'  

# Extend mcollective with online specific extensions
require File.expand_path('../../lib/online/broker/mcollective_ext', File.dirname(__FILE__))
