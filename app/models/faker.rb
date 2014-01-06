class Faker < ActiveRecord::Base
  attr_accessible :api

  has_many :api_prototypes
end
