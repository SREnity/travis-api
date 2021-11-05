# frozen_string_literal: true

module Travis::API::V3
  class InsightsClient
    class ConfigurationError < StandardError; end

    def initialize(user_id)
      @user_id = user_id
    end

    def user_notifications(page, active, order, order_direction)
      page ||= '1'
      query_string = {
        page: page,
        active: active,
        order: order,
        order_dir: order_direction
      }.delete_if { |_, v| v.nil? }.inject('') { |memo, (k, v)| memo += "#{k}=#{URI.encode(v)}" }
      response = connection.get("/user_notifications?#{query_string}")

      handle_errors_and_respond(response) do |body|
        notifications = body['data'].map do |notification|
          Travis::API::V3::Models::Insights::Notification.new(notification)
        end

        Travis::API::V3::Models::Insights::NotificationsCollection.new(notifications, body.fetch('last_page'), body.fetch('page').to_i)
      end
    end

    def toggle_snooze_user_notifications(notification_ids)
      response = connection.put('/user_notifications/toggle_snooze', snooze_ids: notification_ids)

      handle_errors_and_respond(response) do |body|
        notifications = body.map do |notification|
          Travis::API::V3::Models::Insights::Notification.new(notification)
        end

        Travis::API::V3::Models::Insights::NotificationsCollection.new(notifications, 0, 0)
      end
    end

    private

    def handle_errors_and_respond(response)
      case response.status
      when 200, 201
        yield(response.body) if block_given?
      when 202
        true
      when 204
        true
      when 400
        raise Travis::API::V3::ClientError, response.body['error']
      when 403
        raise Travis::API::V3::InsufficientAccess, response.body['rejection_code']
      when 404
        raise Travis::API::V3::NotFound, response.body['error']
      when 422
        raise Travis::API::V3::UnprocessableEntity, response.body['error']
      else
        raise Travis::API::V3::ServerError, 'Insights API failed'
      end
    end

    def connection(timeout: 10)
      @connection ||= Faraday.new(url: insights_url, ssl: { ca_path: '/usr/lib/ssl/certs' }) do |conn|
        conn.basic_auth '_', insights_auth_key
        conn.headers['X-Travis-User-Id'] = @user_id.to_s
        conn.headers['Content-Type'] = 'application/json'
        conn.request :json
        conn.response :json
        conn.options[:open_timeout] = timeout
        conn.options[:timeout] = timeout
        conn.use OpenCensus::Trace::Integrations::FaradayMiddleware if Travis::Api::App::Middleware::OpenCensus.enabled?
        conn.adapter :net_http
      end
    end

    def insights_url
      Travis.config.new_insights.url || raise(ConfigurationError, 'No insights url configured')
    end

    def insights_auth_key
      Travis.config.new_insights.auth_key || raise(ConfigurationError, 'No insights auth key configured')
    end
  end
end
