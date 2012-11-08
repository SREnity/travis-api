module Travis::Api::App::Responders
  class Service < Base
    def apply?
      resource.respond_to?(:run)
    end

    def apply
      cache_control
      result = normalize(resource.run)
      result[:flash] = resource.messages if result && resource.respond_to?(:messages) # TODO should rather happen in the JSON responder, no?
      result
    end

    private

      def cache_control
        if final?
          mode = endpoint.public? ? :public : :private
          endpoint.expires(31536000, mode) # 1 year
        else
          # FIXME: Chrome WTF?
          endpoint.cache_control :no_cache
        end

        endpoint.etag resource.cache_key           if cache_key?
        endpoint.last_modified resource.updated_at if updated_at?
      end

      def final?
        resource.respond_to?(:final?) && resource.final?
      end

      def updated_at?
        resource.respond_to?(:updated_at) && resource.updated_at
      end

      def cache_key?
        resource.respond_to?(:cache_key) && resource.cache_key
      end

      # Services potentially return all sorts of things
      # If it's a string, true or false we'll wrap it into a hash.
      # If it's an active record or scope we just pass so it can be processed by the json responder.
      # If it's nil we also pass it but yield not_found.
      def normalize(result)
        case result
        when String, true, false
          { result: result }
        else
          result
        end
      end
  end
end
