class ApplicationController < ActionController::Base
  #respond_to :html
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  enable_authorization do |exception|
    redirect_to root_url, :alert => exception.message
  end unless :devise_controller?

  analytical 
  def admin_user
    redirect_to(root_url) unless current_user and current_user.admin?
  end
end
