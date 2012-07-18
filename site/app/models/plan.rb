class Plan < RestApi::Base
  schema do
    string :id, :name
  end
  custom_id :id

  def self.all
    [Plan.new({:id => 'freeshift', :name => 'FreeShift'}, true), Plan.new({:id => 'megashift', :name => 'MegaShift'}, true)]
  end
  protected
    def self.find_single(id, options)
      all.find{ |p| p.id == id } or raise ActiveResource::NotFound
    end
end
