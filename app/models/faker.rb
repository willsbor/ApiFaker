class Faker < ActiveRecord::Base
  attr_accessible :api

  has_many :api_prototypes, :dependent => :delete_all
  # accepts_nested_attributes_for :api_prototypes, :allow_destroy => true, :reject_if => :all_blank
end


# [{\"#fake_type#\":\"array\",\"min\":2,\"max\":10,\"#fake_item#\":{\"id\":{\"#fake_type#\":\"integer\", \"min\":1},\"name\":{\"#fake_type#\":\"string\",\"min\":2,\"max\":4},\"money\":{\"#fake_type#\":\"integer\",\"min\":1}, \"fixvalue\": \"abc\"}}]