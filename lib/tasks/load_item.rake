#encoding: utf-8
require 'open-uri'

namespace :data do
  desc 'Loads App Items for directory'
  task :load_items => :environment do
    include RakeMethods

    debug = (ENV['DEBUG'] || false).to_b
    filename = ENV['FILE']
    if filename.blank?
      f = $stdin
    else
      f = File.open(filename)
    end
    csvobj = CSV.new(f)
    
    Item.delete_all
    Tag.delete_all

    header_index = {}
    csvobj.each_with_index do |row, rownum|
      line = rownum+1
      if line == 1
        header_row(row, header_index)
        puts header_index.inspect
        verify_headers(['Name', 'slug', 'raml','swagger_github_url','raml_github_url','Description', 'zapier descripcion','PW description','C Description', 'API Provider', 'Primary Category','Secondary Categories'], header_index)
      else
        slug = row_value(row, 'slug', header_index)
        name = row_value(row, 'Name', header_index)
        raml_id = row_value(row, 'raml', header_index)
        swagger_github_url = row_value(row, 'swagger_github_url', header_index)
        raml_github_url = row_value(row, 'raml_github_url', header_index)
        description = row_value(row, 'Description', header_index)
        c_description = row_value(row, 'C Description', header_index)
        zapier_description = row_value(row, 'zapier descripcion', header_index)
        pw_description = row_value(row, 'PW description', header_index)
        api_provider = row_value(row, 'API Provider', header_index)
        primary_category = row_value(row, 'Primary Category', header_index)
        secondary_categories = []
        secondary_categories = row_value(row, 'Secondary Categories', header_index).split('|') if row_value(row, 'Secondary Categories', header_index).present?
        secondary_categories << primary_category if primary_category.present?
        description ||= c_description || pw_description || zapier_description
        
        if name.blank? || slug.blank?
          # STDERR.puts "line #{line}: name: <#{name}>, slug: #{slug} not found, skipped"
           next
        end
        i = Item.where(slug: slug).first if slug.present?
        if i.blank?
          i = Item.create!(name: name, slug: slug, raml_id: raml_id, description: description, api_provider: api_provider, primary_category: primary_category, raml_github_url: raml_github_url, swagger_github_url: swagger_github_url) unless debug
        else
          i.update_attributes!(name: name, slug: slug,raml_id: raml_id,  description: description, api_provider: api_provider, primary_category: primary_category, raml_github_url: raml_github_url, swagger_github_url: swagger_github_url) unless debug
        end
        
        i.tags = nil

        secondary_categories.uniq.each do |tag_name|
          tag_name = tag_name.parameterize
          unless (tag = Tag.where(name: tag_name).first).present?
            tag = Tag.create!(name: tag_name)
          end
          i.tags << tag
        end
        puts "Setting name: <#{i.name}>, slug: #{i.slug}, description: <#{i.description}>"
      end
    end
    
    list = JSON.load(open("http://apis-guru.github.io/api-models/api/v1/list.json"))
    list.each do |item_name, name_hash|
      preferred = name_hash['preferred']
      main_hash = name_hash['versions'][preferred]['info']
      description = main_hash['description']
      name = main_hash['title']
      logo_url = main_hash['x-logo']['url'] if main_hash['x-logo'].present?
      logo_background_color = main_hash['x-logo']['backgroundColor'] if main_hash['x-logo'].present? && main_hash['x-logo']['backgroundColor'].present?
      swagger_github_url = name_hash['versions'][preferred]['swaggerYamlUrl']
      slug = item_name
      slug = "google-#{slug.split('googleapis.com:')[1]}" if slug.split('googleapis.com:').size > 1
      slug = "citrixonline-#{slug.split('citrixonline.com:')[1]}" if slug.split('citrixonline.com:').size > 1
      slug = slug.split('.')[0]
      api_provider = main_hash['x-origin']['url'] if main_hash['x-origin'].present?
      primary_category = nil
      raml_github_url = nil
      
      if logo_url.blank? ||  name.blank? || slug.blank?
         STDERR.puts "line: name: <#{name}>, slug: #{slug}, logo: #{logo_url}. not found, skipped"
         next
      end
      
      i = Item.where(slug: slug).first if slug.present?
      if i.blank?
        i = Item.create!(name: name, slug: slug, description: description, api_provider: api_provider, primary_category: primary_category, raml_github_url: raml_github_url, swagger_github_url: swagger_github_url, logo_url: logo_url, preferred: preferred, logo_background_color: logo_background_color)
      else
        i.name = name if name.present?
        i.logo_url = logo_url if logo_url.present?
        i.logo_background_color = logo_background_color if logo_background_color.present?
        i.slug = slug if slug.present?
        i.description = description if description.present?
        i.api_provider = api_provider if api_provider.present?
        i.swagger_github_url = swagger_github_url if swagger_github_url.present?
        i.save
      end
      
    end
  end

end
