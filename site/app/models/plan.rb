class Plan < RestApi::Base
  allow_anonymous
  
  schema do
    string :id, :name
    integer :plan_no
  end
  custom_id :id
end
