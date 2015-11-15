#encoding: utf-8

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
        verify_headers(['Name', 'slug', 'raml','Description', 'zapier descripcion','PW description','C Description', 'API Provider', 'Primary Category','Secondary Categories'], header_index)
      else
        slug = row_value(row, 'slug', header_index)
        name = row_value(row, 'Name', header_index)
        raml_id = row_value(row, 'raml', header_index)
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
           STDERR.puts "line #{line}: name: <#{name}>, slug: #{slug} not found, skipped"
           next
         end
        i = Item.where(slug: slug).first if slug.present?
        if i.blank?
          i = Item.create!(name: name, slug: slug, raml_id: raml_id, description: description, api_provider: api_provider, primary_category: primary_category) unless debug
        else
          i.update_attributes!(name: name, slug: slug,raml_id: raml_id,  description: description, api_provider: api_provider, primary_category: primary_category) unless debug
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
  end

end
