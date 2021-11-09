module Travis::API::V3
  class Queries::InsightsNotifications < Query
    params :value, :page, :active, :order, :order_direction, :notification_ids

    def all(user_id)
      insights_client(user_id).user_notifications(
        params['value'],
        params['page'],
        params['active'],
        params['order'],
        params['order_direction']
      )
    end

    def toggle_snooze(user_id)
      insights_client(user_id).toggle_snooze_user_notifications(params['notification_ids'])
    end

    private

    def insights_client(user_id)
      @_insights_client ||= InsightsClient.new(user_id)
    end
  end
end
