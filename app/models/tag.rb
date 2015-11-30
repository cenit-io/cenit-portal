class Tag
  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :items
  has_many :direct_items, class_name: Tag.name, :inverse_of => :primary_category
  field :name, type: String
end
