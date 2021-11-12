# frozen_string_literal: true

module Travis::API::V3
  class Models::InsightsCollection
    def initialize(collection, total_count)
      @collection = collection
      @total_count = total_count
    end

    def count(*)
      @total_count
    end

    def limit(*)
      @collection
    end

    def offset(*)
      @collection
    end
  end
end
