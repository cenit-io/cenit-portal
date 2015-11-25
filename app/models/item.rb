class Item
  include Mongoid::Document
  include Mongoid::Timestamps
  include Rails4Autocomplete::Orm::Mongoid
  
  scope :with_name, -> (name) { where({ name: /#{name}/i })}
  has_and_belongs_to_many :tags
  
  field :name, type: String
  field :slug, type: String
  field :contact_email, type: String
  field :description, type: String
  field :api_provider, type: String
  field :provider_name, type: String
  field :primary_category, type: String
  field :preferred, type: String
  field :logo_url, type: String
  field :logo_background_color, type: String

  field :raml_id, type: String
  field :swagger_json_url, type: String
  field :swagger_yaml_url, type: String
  field :raml_url, type: String
  field :api_homepage, type: String

  field :developer_support, type: String
  field :authentication_mode, type: String
  field :protocol, type: String
  field :endpoint, type: String
  field :homepage, type: String
  field :ssl_support, type: Boolean
  field :sdk, type: String
  field :formats, type: String

  index({
    :slug => 1,
  },
  { :unique => true})

  scopify

end
