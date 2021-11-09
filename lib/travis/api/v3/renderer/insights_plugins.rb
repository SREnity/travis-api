module Travis::API::V3
  class Renderer::InsightsPlugins < CollectionRenderer
    type           :plugins
    collection_key :plugins

    def fields
      super.tap do |fields|
        fields[:@last_page] = last_page
        fields[:@page] = page
      end
    end

    private

    def list
      @list.plugins
    end

    def last_page
      @list.last_page
    end

    def page
      @list.page
    end
  end
end
