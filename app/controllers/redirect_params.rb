module RedirectParams
  extend ActiveSupport::Concern

  included do

    before_filter do
      if (return_to = (resource_data = params[resource_name]) && resource_data[:return_to])
        session["#{resource_name}_return_to"] = return_to
      end
    end
  end
end