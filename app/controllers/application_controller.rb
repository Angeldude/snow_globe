class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :set_paper_trail_whodunnit

  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # START: current_user_override
  def current_user
    return nil if session[:awaiting_authy_user_id].present?
    super
  end
  # END: current_user_override

  def authenticate_admin_user!
    raise Pundit::NotAuthorizedError unless current_user&.admin?
  end

  private def user_not_authorized
    sign_out(User)
    render plain: "Access Not Allowed", status: :forbidden
  end

end
