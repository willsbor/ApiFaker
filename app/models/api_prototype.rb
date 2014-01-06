class ApiPrototype < ActiveRecord::Base
  attr_accessible :faker_id, :prototype

  belongs_to :faker
end
