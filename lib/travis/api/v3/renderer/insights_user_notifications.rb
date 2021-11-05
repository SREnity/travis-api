module Travis::API::V3
  class Renderer::InsightsUserNotifications < CollectionRenderer
    type           :notifications
    collection_key :notifications

    def fields
      super.tap do |fields|
        fields[:@last_page] = last_page
        fields[:@page] = page
      end
    end

    private

    def list
      @list.notifications
    end

    def last_page
      @list.last_page
    end

    def page
      @list.page
    end
  end
end
