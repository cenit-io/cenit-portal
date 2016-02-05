module DeviseHelper
  # A simple way to show error messages for the current devise resource. If you need
  # to customize this method, you can either overwrite it in your application helpers or
  # copy the views to your application.
  #
  # This method is intended to stay simple and it is unlikely that we are going to change
  # it to add more behavior or options.
  def devise_error_messages!
    return "" if resource.errors.empty?

    html = <<-HTML
      <div class="alert alert-danger col-xs-12 fade in">
        <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
        <strong class="col-xs-2 col-sm-1">Error(s)!</strong>
        <div class="col-xs-9 col-sm-10">
    HTML
    resource.errors.full_messages.each { |msg|
      html += <<-HTML
         <div>#{msg}</div>
      HTML
    }

    html += '</div></div>'
    html.html_safe
  end
end
