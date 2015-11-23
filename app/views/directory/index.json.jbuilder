json.array!(@items) do |item|
  json.extract! item, :id, :name
  json.url directory_url(item, format: :json)
end
