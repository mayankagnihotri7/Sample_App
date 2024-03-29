class ApplicationController < ActionController::Base
  include SessionsHelper

  private
    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in first."
        redirect_to login_path
      end
    end
end
