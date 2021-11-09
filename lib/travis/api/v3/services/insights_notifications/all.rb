module Travis::API::V3
  class Services::InsightsNotifications::All < Service
    params :value, :page, :active, :order, :order_direction

    def run!
      raise LoginRequired unless access_control.full_access_or_logged_in?
      result query(:insights_notifications).all(access_control.user.id)
    end
  end
end
