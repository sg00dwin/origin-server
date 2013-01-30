ApplicationObserver.instance
CloudUserObserver.instance
DomainObserver.instance
BillingObserver.instance
#customizations to models
require 'cloud_user_ext' 

# Extend mcollective with express specific extensions
require File.expand_path('../../lib/express/broker/mcollective_ext', File.dirname(__FILE__))
