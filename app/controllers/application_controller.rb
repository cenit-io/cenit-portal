class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  include RedirectParams

  helper_method :resource, :resource_name, :devise_mapping

  #protect_from_forgery with: :null_session,
  #  if: Proc.new { |c| c.request.format =~ %r{application/json} }

  # protect_from_forgery with: :null_session

  skip_before_action :verify_authenticity_token

  #protect_from_forgery    
  #skip_before_action :verify_authenticity_token, if: true   


  def resource_name
    :user
  end

  def resource
    @user = @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_path, :alert => exception.message
  end

  def about_us
  end

  def contact_us
  end

  def features
  end

  def services
  end

  protected

  def json_request?
    request.format.json?
  end

end