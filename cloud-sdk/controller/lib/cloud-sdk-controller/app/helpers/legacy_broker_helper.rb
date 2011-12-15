module LegacyBrokerHelper
  def get_cached(key, opts={})
    unless Rails.application.config.action_controller.perform_caching
      if block_given?
        return yield
      end
    end
  
    val = Rails.cache.read(key)
    unless val
      if block_given?
        val = yield
        if val
          Rails.cache.write(key, val, opts)
        end
      end
    end
  
    return val
  end
end