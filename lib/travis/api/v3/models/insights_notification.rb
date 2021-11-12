module Travis::API::V3
  class Models::InsightsNotification
    attr_reader :id, :type, :active, :weight, :message, :plugin_name, :plugin_type, :plugin_category

    def initialize(attributes = {})
      @id = attributes.fetch('id')
      @type = attributes.fetch('type')
      @active = attributes.fetch('active')
      @weight = attributes.fetch('weight')
      @message = attributes.fetch('message')
      @plugin_name = attributes.fetch('plugin_name')
      @plugin_type = attributes.fetch('plugin_type')
      @plugin_category = attributes.fetch('plugin_category')
    end
  end
end
