class Plan < RestApi::Base
  allow_anonymous

  schema do
    string :id, :name
    integer :plan_no
  end
  custom_id :id

  class Capability < RestApi::Base; end
  has_one :capabilities, :class_name => 'plan/capability'

  def basic?
    id == 'freeshift'
  end

  cache_method :find_single, lambda{ |*args| [Plan.name, :find_single, args[0]] }, :before => remove_authorization_from_model
  cache_find_method :every
end
