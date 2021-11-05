module Travis::API::V3
  class Models::Insights::Notification
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

  class Models::Insights::NotificationsCollection
    attr_reader :notifications, :last_page, :page
    def initialize(notifications, last_page, page)
      @notifications = notifications
      @last_page = last_page
      @page = page
    end
  end
end
