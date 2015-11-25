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
        verify_headers(['name', 'slug', 'preferred', 'raml','raml_url','logo_url','logo_background_color','description','zapier_descripcion','pw_description','c_description','api_provider','primary_category','secondary_categories'], header_index)
      else
        slug = row_value(row, 'slug', header_index)
        name = row_value(row, 'name', header_index)
        raml_id = row_value(row, 'raml', header_index)
        raml_url = row_value(row, 'raml_url', header_index)
        
        description = row_value(row, 'description', header_index)
        c_description = row_value(row, 'c_description', header_index)
        zapier_description = row_value(row, 'zapier_descripcion', header_index)
        pw_description = row_value(row, 'pw_description', header_index)
        
        api_provider = row_value(row, 'api_provider', header_index)
        provider_name = row_value(row, 'provider_name', header_index)
        
        logo_url = row_value(row, 'logo_url', header_index)
        logo_background_color = row_value(row, 'logo_background_color', header_index)
        preferred = row_value(row, 'preferred', header_index)
        
        primary_category = row_value(row, 'primary_category', header_index)
        secondary_categories = []
        secondary_categories = row_value(row, 'secondary_categories', header_index).split('|') if row_value(row, 'secondary_categories', header_index).present?
        secondary_categories << primary_category if primary_category.present?
        description ||= c_description || pw_description || zapier_description
        
        if name.blank? || slug.blank?
          # STDERR.puts "line #{line}: name: <#{name}>, slug: #{slug} not found, skipped"
           next
        end
        i = Item.where(slug: slug).first if slug.present?
        if i.blank?
          i = Item.create!({
          name: name, 
          slug: slug,
          primary_category: primary_category,
          description: description, 
          api_provider: api_provider, 
          raml_id: raml_id, 
          raml_url: raml_url,
          logo_url: logo_url, 
          preferred: preferred, 
          logo_background_color: logo_background_color})
        else
          i.name = name if name.present?
          i.primary_category =  primary_category if primary_category.present?
          i.logo_url = logo_url if logo_url.present?
          i.logo_background_color = logo_background_color if logo_background_color.present?
          i.slug = slug if slug.present?
          i.description = description if description.present?
          i.api_provider = api_provider if api_provider.present?
          i.preferred = preferred if preferred.present?
          i.primary_category = primary_category if primary_category.present?
          i.raml_url = raml_url if raml_url.present?
          i.raml_id = raml_id if raml_id.present?
          i.save
        end
        
        i.tags = nil

        secondary_categories.uniq.each do |tag_name|
          tag_name = tag_name.parameterize
          unless (tag = Tag.where(name: tag_name).first).present?
            tag = Tag.create!(name: tag_name)
          end
          i.tags << tag
        end
        puts "."
      end
    end
  
  #/////////////////////////////////////////////////////////////////////////////////////////////////  
  
  filename = 'lib/data/pw.csv'
  f = File.open(filename)
  csvobj = CSV.new(f)

  header_index = {}
  csvobj.each_with_index do |row, rownum|
    line = rownum+1
    if line == 1
      header_row(row, header_index)
      puts header_index.inspect
      verify_headers(
      ['url','title','description','followers','API_Endpoint','API_Forum','API_Homepage','API_Kits','API_Provider',
        'Authentication_Mode','Console_URL','Contact_Email','Developer_Support','Other_options','Primary_Category',
        'Protocol_Formats','Secondary_Categories','SSL_Support','Twitter_Url'], header_index)
    else
      title = row_value(row, 'title', header_index)
      slug = title.parameterize.split('-api')[0]
      description = row_value(row, 'description', header_index)
      api_provider = row_value(row, 'API_Provider', header_index)
      primary_category = row_value(row, 'Primary_Category', header_index)
      api_homepage = row_value(row, 'API_Homepage', header_index)

      secondary_categories = []
      secondary_categories = row_value(row, 'Secondary_Categories', header_index).split('|') if row_value(row, 'secondary_categories', header_index).present?
      secondary_categories << primary_category if primary_category.present?
      
      next unless (i = Item.where(slug: slug).first).present?

      i.primary_category =  primary_category if i.primary_category.nil? && primary_category.present?
      i.description = description if i.description.nil? && description.present?
      i.api_provider = api_provider if  i.api_provider.nil? &&  api_provider.present?
      i.primary_category = primary_category if i.primary_category.nil? && primary_category.present?
      i.api_homepage = api_homepage if i.api_homepage.nil? && api_homepage.present?
      i.save
      
      next if  ['streak','zenpayroll','eventjoy','sina-weibo','hackpad','launchrock','datasift','bintray', 'bing-ads','stride','taskrabbit','uber','hellofax','klout','papertrail'].include? i.slug
      
      unless i.tags.any?
        
        secondary_categories.uniq.each do |tag_name|
          next if ['Aggregation Real Time Semantics'].include? tag_name
          tag_name.gsub(/(Internet Of Things Security)/i, 'Internet Of Things')
          tag_name.gsub(/(Accounting Accounting Merchants Business)/i, 'Accounting')
          tag_name.gsub(/(Events)/i, 'Event Management')
          tag_name.gsub(/(Contacts Customer Relationship Management Email)/i, 'CRM')
          tag_name.gsub(/(Advertising Marketing)/i, 'Marketing')
          tag_name.gsub(/(Collaboration Sales)/i, 'Collaboration')
          tag_name.gsub(/(Campaigns Management Reporting Search)/i, 'Reporting')
          tag_name.gsub(/(Blogging Chinese)/i, 'Blogging')
          
          tag_name.gsub(/(File Sharing)/i, 'File Management')
          tag_name.gsub(/(Financial Enterprise)/i, 'Financial')
          tag_name.gsub(/(Geography Location Prices Real Time Travel)/i, 'Location')
          tag_name.gsub(/(Home Automation)/i, 'Internet Of Things')
          tag_name.gsub(/(Sales Marketing Voice Webhooks)/i, 'Marketing')
          tag_name.gsub(/(Social Reputation Sentiment)/i, 'Sentiment Analysis')
          tag_name.gsub(/(Social Social)/i, 'Social')
          tag_name.gsub(/(Social Social Collaboration)/i, 'Collaboration')
          tag_name.gsub(/(Surveys Marketing)/i, 'Marketing')
        
          tag_name = tag_name.parameterize
          
          
          unless (tag = Tag.where(name: tag_name).first).present?
            tag = Tag.create!(name: tag_name)
          end
          i.tags << tag
        end
      end
      
      puts "Setting name: <#{i.name}>, slug: #{i.slug}"
    end
  end
  
  
  #/////////////////////////////////////////////////////////////////////////////////////////////////  
    list = JSON.load(open("http://apis-guru.github.io/api-models/api/v1/list.json"))
    list.each do |item_name, name_hash|
      preferred = name_hash['preferred']
      main_hash = name_hash['versions'][preferred]['info']
      description = main_hash['description']
      name = main_hash['title']
      
      logo_url = main_hash['x-logo']['url'] if main_hash['x-logo'].present?
      logo_background_color = main_hash['x-logo']['backgroundColor'] if main_hash['x-logo'].present? && main_hash['x-logo']['backgroundColor'].present?
      
      swagger_yaml_url = name_hash['versions'][preferred]['swaggerYamlUrl']
      swagger_json_url = name_hash['versions'][preferred]['swaggerUrl']
      
      slug = item_name
      slug = "google-#{slug.split('googleapis.com:')[1]}" if slug.split('googleapis.com:').size > 1
      slug = "citrixonline-#{slug.split('citrixonline.com:')[1]}" if slug.split('citrixonline.com:').size > 1
      slug = slug.split('.')[0]
      
      api_provider = main_hash['x-origin']['url'] if main_hash['x-origin'].present?
      provider_name = main_hash['x-providerName'] if main_hash['x-providerName'].present?
      
      if logo_url.blank? ||  name.blank? || slug.blank?
         STDERR.puts "line: name: <#{name}>, slug: #{slug}, logo: #{logo_url}. not found, skipped"
         next
      end
      
      i = Item.where(slug: slug).first if slug.present?
      if i.blank?
        i = Item.create!({
        name: name, 
        slug: slug, 
        description: description,
        provider_name: provider_name, 
        api_provider: api_provider, 
        swagger_json_url: swagger_json_url, 
        swagger_yaml_url: swagger_yaml_url, 
        preferred: preferred, 
        logo_url: logo_url, 
        logo_background_color: logo_background_color})
      else
        i.name = name if name.present?
        i.logo_url = logo_url if logo_url.present?
        i.logo_background_color = logo_background_color if logo_background_color.present?
        i.description = description if description.present?
        i.provider_name = provider_name if provider_name.present?
        i.api_provider = api_provider if api_provider.present?
        i.preferred = preferred if preferred.present?
        i.swagger_json_url = swagger_json_url if swagger_json_url.present?
        i.swagger_yaml_url = swagger_yaml_url if swagger_yaml_url.present?
        i.save
      end
      
    end
  end

end
