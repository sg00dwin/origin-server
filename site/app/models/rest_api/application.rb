module RestApi
  #
  # The REST API model object representing an application instance.
  #
  class Application < Base
    schema do
      string :name, :creation_time
      string :uuid, :domain_id
      string :cartridge, :server_identity
    end

    custom_id :name

    has_many :aliases
    belongs_to :domain
    self.prefix = "#{RestApi.site.path}/domains/:domain_name/"

    def domain_id
      self.prefix_options[:domain_name] || super
    end
    def domain_id=(id)
      self.prefix_options[:domain_name] = id
      domain_id = id
    end

    # TODO: Bug 789752: Rename server attribute to domain_name and replace domain_id with domain_name everywhere
    def domain_name
      domain_id
    end
    def domain_name=(name)
      domain_id = name
    end

    def domain
      Domain.find domain_name, :as => as
    end
    def domain=(domain)
      domain_name = domain.is_a?(String) ? domain : domain.namespace
    end

    def web_url
      'http://' << url_authority
    end
    def git_url
      "ssh://#{uuid}@#{url_authority}/~/git/#{name}.git/"
    end

    protected
      def url_authority
        "#{name}-#{domain_name}.#{Rails.configuration.base_domain}"
      end
  end
end


