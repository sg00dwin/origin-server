module RestApi
  #
  # The REST API model object representing a domain name alias to an application.
  #
  class Alias < Base
    schema do
      string :name
    end

    belongs_to :application
  end
end
