#encoding: utf-8
require 'open-uri'

require "google_drive"

session = GoogleDrive.saved_session("config.json")

namespace :data do
  desc 'Loads App Items for directory'
  task :load_items_from_drive => :environment do

    ws = session.spreadsheet_by_key(ENV['SPREADSHEETS_ID']).worksheets[0]
    
    Item.delete_all
    Tag.delete_all

    (2..ws.num_rows).each do |row|

        slug =                                   ws[row, 1] # A
        name =                                   ws[row, 2] # B
        api_provider =                           ws[row, 3] # C
                                                 ws[row, 4] # D
        logo_url =                               ws[row, 5] # E
        logo_background_color =                  ws[row, 6] # F
        preferred =                              ws[row, 7] # G
        provider_name =                          ws[row, 8] # H
        raml_id =                                ws[row, 9] # I
        raml_url =                               ws[row, 10]# J 
        description =                            ws[row, 11]# K
        zapier_description =                     ws[row, 12]# L
        pw_description =                         ws[row, 13]# M
        c_description =                          ws[row, 14]# N
                                                 ws[row, 15]# O
                                                 ws[row, 16]# P
        primary_category =                       ws[row, 17]# Q
        secondary_categories =                   ws[row, 18]# R
  
                                                                                   

        secondary_categories = secondary_categories.split('|')
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
        #  swagger_ui_url: swagger_ui_url,
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
      #   i.swagger_ui_url = swagger_ui_url if swagger_ui_url.present?
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
        
        i.save!
        
        puts "."
    end
    
   #/////////////////////////////////////////////////////////////////////////////////////////////////  
  

    ws = session.spreadsheet_by_key(ENV['SPREADSHEETS_PW_ID']).worksheets[0]
    

    (2..ws.num_rows).each do |row|
                                               ws[row, 1] # A
      title =                                  ws[row, 2] # B
      description =                            ws[row, 3] # C
                                               ws[row, 4] # D 
                                               ws[row, 5] # E
                                               ws[row, 6] # F
      api_homepage =                           ws[row, 7] # G
                                               ws[row, 8] # H
      api_provider =                           ws[row, 9] # I
                                               ws[row, 10]# J 
                                               ws[row, 11]# K
                                               ws[row, 12]# L
                                               ws[row, 13]# M
                                               ws[row, 14]# N
      primary_category =                       ws[row, 15]# O
                                               ws[row, 16]# P
      secondary_categories =                   ws[row, 17]# Q

      slug = title.parameterize.split('-api')[0]
      secondary_categories = secondary_categories.split('|')
      secondary_categories << primary_category if primary_category.present?
      
      next unless (i = Item.where(slug: slug).first).present?

      i.description = description if i.description.nil? && description.present?
      i.api_provider = api_provider if  i.api_provider.nil? &&  api_provider.present?
      i.api_homepage = api_homepage if i.api_homepage.nil? && api_homepage.present?

      primary = false
      secondary_categories.uniq.each do |tag_name|
        primary = true if tag_name == primary_category
        
        next if tag_name == 'Applications'

        tag_name.gsub!(/(Customer Relationship Management)/i, 'CRM')
        tag_name.gsub!(/(Business Crm)/i, 'CRM')
        tag_name.gsub!(/(File Sharing)/i, 'File Management')
        tag_name.gsub!(/(Cloud Storage)/i, 'File Management')
        tag_name.gsub!(/(Crm Business)/i, 'CRM')
        tag_name.gsub!(/(Customer Service)/i, 'Help Desk')
        tag_name.gsub!(/(Application Developmen)/i, 'Developer Tools')
        tag_name = 'Event Management' if tag_name == 'Events' || tag_name == 'Event'
        tag_name = 'Project Management' if tag_name == 'Tasks'
        tag_name = 'Payment Processing' if tag_name == 'Payments'
        tag_name = 'Cloud Platform' if tag_name == 'Cloud'
        tag_name = 'Project Management' if tag_name == 'Project Hosting'
        tag_name = 'Business' if tag_name == 'Marketing Business'
        
        tag_name.gsub!(/(Bookmarking)/i, 'Bookmarks')

        tag_name.gsub!('Toolst', 'Tools')
        tag_name.gsub!(/(Hr)/i, 'Human Resources')
        tag_name.gsub!(/(Mobile Applications)/i, 'Mobile')
        tag_name.gsub!(/(Lists Tasks)/i, 'Payment Processing')
        
        tag_name.gsub!(/(Marketing Business)/i, 'Marketing')
        tag_name.gsub!(/(Event Managements)/i, 'Event Management')
        tag_name.gsub!(/(Project Hosting)/i, 'Project Management')
        
        tag_name = tag_name.parameterize

        unless (tag = Tag.where(name: tag_name).first).present?
          tag = Tag.create!(name: tag_name)
        end
        
        i.tags << tag unless i.tags.include? tag
        
        if primary
          i.primary_category = tag if i.primary_category.nil?
          primary = false
        end
        
        i.save!
      end
      
      puts "Setting name: <#{i.name}>, slug: #{i.slug}"
    end
    
    #/////////////////////////////////////////////////////////////////////////////////////////////////  
    list = JSON.load(open("http://api.apis.guru/v2/list.json"))
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
