class ApplicationController < ActionController::Base
  before_action :record_user_activity
  def record_user_activity
    if current_user
      current_user.touch :last_active_at
    end
  end
end
