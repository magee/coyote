# @abstract Base class for all Coyote controllers
class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery :with => :exception

  before_action :store_user_location!, :if => :storable_location? # see https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, :if => :devise_controller?

  skip_before_action :authenticate_user!, if: ->(controller) { controller.instance_of?(HighVoltage::PagesController) }

  analytical

  helper_method :current_organization, :current_organization?, :organization_user, :pagination_link_params, :filter_params

  protected

  def organization_scope
    # can't do this in Pundit, since Pundit needs the results of this scoping
    if current_user.staff?
      Organization.all
    else
      Organization.joins(:memberships).where(memberships: { user: current_user })
    end
  end

  def organization_user
    @organization_user ||= Coyote::OrganizationUser.new(current_user,current_organization)
  end

  alias pundit_user organization_user

  def after_sign_in_path_for(user)
    original_path = stored_location_for(:user)

    if original_path != root_path
      original_path
    elsif user.organizations.one?
      organization_path(user.organizations.first)
    else
      organizations_path
    end
  end

  def current_organization?
    organization_scope.exists?(params[:organization_id])
  end

  def current_organization
    @current_organization ||= organization_scope.find(params[:organization_id])
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update,keys: %i[first_name last_name])
  end

  def pagination_params
    params.fetch(:page,{}).permit(:number,:size)
  end

  private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr? 
  end

  def store_user_location!
    store_location_for(:user,request.fullpath)
  end
end
