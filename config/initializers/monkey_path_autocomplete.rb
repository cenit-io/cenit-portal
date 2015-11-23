module Rails4Autocomplete
  module Autocomplete
    module ClassMethods
      def autocomplete(object, method, options = {})
        define_method("autocomplete_#{object}_#{method}") do

          method = options[:column_name] if options.has_key?(:column_name)

          term = params[:term]

          if term && !term.blank?
            #allow specifying fully qualified class name for model object
            class_name = options[:class_name] || object
            items = autocomplete_items(:model => get_object(class_name), \
              :options => options, :term => term, :method => method)
          else
            items = {}
          end

          render :json => json_for_autocomplete(items, options[:display_value] ||= method, options[:extra_data])
        end
      end
    end
  end
end
