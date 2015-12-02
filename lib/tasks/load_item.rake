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
        verify_headers(['name', 'slug', 'preferred', 'any_api','raml','raml_url','logo_url','logo_background_color','description','zapier_descripcion','pw_description','c_description','api_provider','primary_category','secondary_categories'], header_index)
      else
        slug = row_value(row, 'slug', header_index)
        name = row_value(row, 'name', header_index)
        swagger_ui_url = row_value(row, 'any_api', header_index)
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
          description: description, 
          api_provider: api_provider,
          swagger_ui_url: swagger_ui_url,
          raml_id: raml_id, 
          raml_url: raml_url,
          logo_url: logo_url, 
          preferred: preferred, 
          logo_background_color: logo_background_color})
        else
          i.name = name if name.present?
          i.logo_url = logo_url if logo_url.present?
          i.logo_background_color = logo_background_color if logo_background_color.present?
          i.slug = slug if slug.present?
          i.description = description if description.present?
          i.api_provider = api_provider if api_provider.present?
          i.preferred = preferred if preferred.present?
          i.swagger_ui_url = swagger_ui_url if swagger_ui_url.present?
          i.raml_url = raml_url if raml_url.present?
          i.raml_id = raml_id if raml_id.present?
          
        end
        primary = false 
        secondary_categories.uniq.each do |tag_name|
          primary = true if tag_name == primary_category
          tag_name = tag_name.parameterize
          unless (tag = Tag.where(name: tag_name).first).present?
            tag = Tag.create!(name: tag_name)
          end
          
          if primary
            i.primary_category = tag 
            primary = false
          end
          
          i.tags << tag unless i.tags.include? tag
        end
        
        i.save
        
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

      i.description = description if i.description.nil? && description.present?
      i.api_provider = api_provider if  i.api_provider.nil? &&  api_provider.present?
      i.api_homepage = api_homepage if i.api_homepage.nil? && api_homepage.present?

      primary = false
      secondary_categories.uniq.each do |tag_name|
        primary = true if tag_name == primary_category

        tag_name.gsub!(/(Customer Relationship Management)/i, 'CRM')
        tag_name.gsub!(/(Business Crm)/i, 'CRM')
        tag_name.gsub!(/(File Sharing)/i, 'File Management')
        tag_name.gsub!(/(Crm Business)/i, 'CRM')
        tag_name.gsub!(/(Customer Service)/i, 'Help Desk')
        tag_name.gsub!(/(Application Developmen)/i, 'Developer Tools')
        tag_name.gsub!(/(Developer)/i, 'Developer Tools')
        tag_name.gsub!(/(Event)/i, 'Event Management')
        tag_name.gsub!(/(Hr)/i, 'Human Resources')
        tag_name.gsub!(/(Mobile Applications)/i, 'Mobile')
        tag_name.gsub!(/(Payments)/i, 'Payment Processing')
        tag_name.gsub!(/(Lists Tasks)/i, 'Payment Processing')
        tag_name.gsub!(/(Tasks)/i, 'Project Management')
        tag_name.gsub!(/(Marketing Business)/i, 'Marketing')
        
        
        tag_name = tag_name.parameterize

        unless (tag = Tag.where(name: tag_name).first).present?
          tag = Tag.create!(name: tag_name)
        end
        i.tags << tag unless i.tags.include? tag
        
        if primary
          i.primary_category = tag if i.primary_category.nil?
          primary = false
        end
        
        i.save
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
      slug = "hetras-certification-#{slug.split('hetras-certification.net:')[1]}" if slug.split('hetras-certification.net:').size > 1
      
      slug = "nrel-gov-#{slug.split('nrel.gov:')[1]}" if slug.split('nrel.gov:').size > 1
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
      
      Tag.all.each do |tag|
        if tag.items.size < 3
          tag.delete
        end
      end
      
    end
  end

end
