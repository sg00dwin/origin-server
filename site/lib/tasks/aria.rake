namespace :aria do
  desc 'Update Aria with the direct post settings for this server.'
  task :set_direct_post => :environment do
    name_prefix = Rails.configuration.aria_direct_post_name
    raise "aria_direct_post_name is nil (development mode).  This task requires it to be set." if name_prefix.nil?
    base = Rails.configuration.aria_direct_post_redirect_base
    raise "aria_direct_post_redirect_base is nil (development mode).  This task requires it to be set." if base.nil?

    urls = Rails.application.routes.url_helpers

    puts "Set direct post configuration for default edit"
    Aria::DirectPost.create(nil, "#{base}#{urls.direct_update_account_payment_method_path}")

    Plan.all.each do |plan|
      name = Aria::DirectPost.get_configured(plan)
      path = urls.direct_create_account_plan_upgrade_payment_method_path(plan)
      url = "#{base}#{path}"
      puts "Set direct post configuration '#{name}' to redirect to '#{url}'"

      Aria::DirectPost.create(plan, url)
      puts "  Settings: #{Aria.get_reg_uss_config_params("direct_post_#{name}").inspect}"
    end
  end

  desc 'Reset all API only Aria resources to their default state'
  task :clean => :environment do
    puts "Deleting config params for default direct post"
    Aria::DirectPost.destroy

    Plan.all.each do |plan| 
      if name = Aria::DirectPost.get_configured(plan)
        puts "Deleting config params for direct post #{name}"
        Aria::DirectPost.destroy(name)
      end
    end
  end

  desc 'Check that the configuration is valid.'
  task :check => :environment do
  end
end
