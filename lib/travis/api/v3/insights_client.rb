# frozen_string_literal: true

module Travis::API::V3
  class InsightsClient
    class ConfigurationError < StandardError; end

    def initialize(user_id)
      @user_id = user_id
    end

    def user_notifications(filter, page, active, sort_by, sort_direction)
      query_string = query_string_from_params(
        value: filter,
        page: page || '1',
        active: active,
        order: sort_by,
        order_dir: sort_direction
      )
      response = connection.get("/user_notifications?#{query_string}")

      handle_errors_and_respond(response) do |body|
        notifications = body['data'].map do |notification|
          Travis::API::V3::Models::InsightsNotification.new(notification)
        end

        Travis::API::V3::Models::InsightsCollection.new(notifications, body.fetch('total_count'))
      end
    end

    def toggle_snooze_user_notifications(notification_ids)
      response = connection.put('/user_notifications/toggle_snooze', snooze_ids: notification_ids)

      handle_errors_and_respond(response)
    end

    def user_plugins(filter, page, active, sort_by, sort_direction)
      query_string = query_string_from_params(
        value: filter,
        page: page || '1',
        active: active,
        order: sort_by,
        order_dir: sort_direction
      )
      response = connection.get("/user_plugins?#{query_string}")

      handle_errors_and_respond(response) do |body|
        plugins = body['data'].map do |plugin|
          Travis::API::V3::Models::InsightsPlugin.new(plugin)
        end

        Travis::API::V3::Models::InsightsCollection.new(plugins, body.fetch('total_count'))
      end
    end

    def create_plugin(params)
      response = connection.post("/user_plugins", user_plugin: params)
      handle_errors_and_respond(response) do |body|
        Travis::API::V3::Models::InsightsPlugin.new(body['plugin'])
      end
    end

    def toggle_active_plugins(plugin_ids)
      response = connection.put('/user_plugins/toggle_active', toggle_ids: plugin_ids)

      handle_errors_and_respond(response) do |body|
        Travis::API::V3::Models::InsightsCollection.new([], 0)
      end
    end

    def delete_many_plugins(plugin_ids)
      response = connection.delete('/user_plugins/delete_many', delete_ids: plugin_ids)

      handle_errors_and_respond(response) do |body|
        Travis::API::V3::Models::InsightsCollection.new([], 0)
      end
    end

    def generate_key(plugin_name, plugin_type)
      response = connection.get('/user_plugins/generate_key', name: plugin_name, plugin_type: plugin_type)

      handle_errors_and_respond(response) do |body|
        body
      end
    end

    def authenticate_key(params)
      response = connection.post('/user_plugins/authenticate_key', params)

      handle_errors_and_respond(response) do |body|
        body
      end
    end

    def public_key
      response = connection.get('/api/v1/public_keys/latest.json')

      handle_errors_and_respond(response) do |body|
        Travis::API::V3::Models::InsightsPublicKey.new(body)
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

    def query_string_from_params(params)
      params.delete_if { |_, v| v.nil? || v.empty? }.to_query
    end
  end
end
