module Travis::API::V3
  class Services::InsightsPlugins::All < Service
    params :value, :page, :active, :order, :order_direction

    def run!
      raise LoginRequired unless access_control.full_access_or_logged_in?
      result query(:insights_plugins).all(access_control.user.id)
    end
  end
end
