class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  
  helper_method :resource, :resource_name, :devise_mapping
  
  protect_from_forgery with: :null_session,
    if: Proc.new { |c| c.request.format =~ %r{application/json} }
  
  #protect_from_forgery
  
  def resource_name
     :user
   end

   def resource
     @resource ||= User.new
   end

   def devise_mapping
     @devise_mapping ||= Devise.mappings[:user]
   end
   
  rescue_from CanCan::AccessDenied do |exception|
     redirect_to main_app.root_path, :alert => exception.message
   end
  
  around_filter :scope_current_account
  
  def about_us
  end

  def contact_us
  end

  def features
  end

  def services
  end

  private
  
    def scope_current_account
      if current_user && current_user.account.nil?
         current_user.add_role(:admin) unless current_user.has_role?(:admin)
         current_user.account = Account.create_with_owner(owner: current_user)
         current_user.save(validate: false)
       end 
      Account.current = current_user.account if signed_in?
      yield
    ensure
      Account.current = nil
    end
  
end