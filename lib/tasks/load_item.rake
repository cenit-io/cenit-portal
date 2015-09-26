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
 
    header_index = {}
    csvobj.each_with_index do |row, rownum|
      line = rownum+1
      if line == 1
        header_row(row, header_index)
        verify_headers(['Name', 'slug', 'Description'], header_index)
      else
        slug = row_value(row, 'slug', header_index)
        name = row_value(row, 'Name', header_index)
        description = row_value(row, 'Description', header_index)
        if name.blank? || slug.blank?
           STDERR.puts "line #{line}: name: <#{name}>, slug: #{slug} not found, skipped"
           next
         end
        i = Item.where(slug: slug).first if slug.present?
        if i.blank?
          i = Item.create!(name: name, slug: slug, description: description) unless debug
        else
          i.update_attributes!(name: name, slug: slug, description: description) unless debug
        end
        puts "Setting name: <#{i.name}>, slug: #{i.slug}, description: <#{i.description}>"
      end
    end
  end

end
