module RestApi
  #
  # The REST API model object representing the domain, which may contain multiple applications.
  #
  class Domain < Base
    schema do
      string :namespace
      string :ssh
    end

    custom_id :namespace, true

    has_many :applications
    def applications
      Application.find :all, { :params => { :domain_name => namespace }, :as => as }
    end

    belongs_to :user
    def user
      User.find :one, :as => as
    end

    def destroy_recursive
      connection.delete(element_path({:force => true}.merge(prefix_options)), self.class.headers)
    end
  end
end
