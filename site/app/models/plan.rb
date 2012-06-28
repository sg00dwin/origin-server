class Plan < RestApi::Base
  schema do
    string :id, :name
  end
  custom_id :id
end
