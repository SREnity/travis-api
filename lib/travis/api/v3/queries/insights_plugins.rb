module Travis::API::V3
  class Queries::InsightsPlugins < Query
    params :value, :page, :active, :order, :order_direction

    def all(user_id)
      insights_client(user_id).user_plugins(
        params['value'],
        params['page'],
        params['active'],
        params['order'],
        params['order_direction']
      )
    end

    private

    def insights_client(user_id)
      @_insights_client ||= InsightsClient.new(user_id)
    end
  end
end
