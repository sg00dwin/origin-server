# Be sure to restart your server when you modify this file.

RedHatCloud::Application.config.session_store :cookie_store, :key => '_rhc_session',
                                                             :secure => !Rails.env.development?, # Only send cookie over SSL when in production mode
                                                             :http_only => true, # Don't allow Javascript to access the cookie (mitigates cookie-based XSS exploits)
                                                             :expire_after => nil


# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# RedHatCloud::Application.config.session_store :active_record_store
