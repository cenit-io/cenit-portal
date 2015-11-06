class Item
  include Mongoid::Document
  
  scope :with_name, -> (name) { where({ name: /#{name}/i })}
  
  field :name, :type => String
  field :slug, :type => String
  field :description, :type => String
  field :api_provider, :type => String
  field :primary_category, :type => String
  field :endpoint, :type => String
  field :homepage, :type => String
  field :protocol, :type => String
  field :formats, :type => String
  field :last_version, :type => String
  field :ssl_support, :type => Boolean
  field :sdk, :type => String
  field :raml_id, :type => String
  field :developer_support, :type => String
  field :authentication_mode, :type => String

  index({
    :slug => 1,
  },
  { :unique => true})

  scopify
end
