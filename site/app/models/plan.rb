class Plan < RestApi::Base
  allow_anonymous

  schema do
    string :id, :name
    integer :plan_no
  end
  custom_id :id

  has_one :capabilities, :class_name => as_indifferent_hash

  def basic?
    id == 'free'
  end

  cache_method :find_single, lambda{ |*args| [Plan.name, :find_single, args[0]] }, :before => remove_authorization_from_model
  cache_find_method :every

end
