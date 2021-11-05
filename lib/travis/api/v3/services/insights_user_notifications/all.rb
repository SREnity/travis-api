module Travis::API::V3
  class Services::InsightsUserNotifications::All < Service
    params :page, :active, :order, :order_dir

    def run!
      raise LoginRequired unless access_control.full_access_or_logged_in?
      result query(:insights_user_notifications).all(access_control.user.id)
    end
  end
end
