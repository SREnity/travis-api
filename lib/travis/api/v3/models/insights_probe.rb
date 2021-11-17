module Travis::API::V3
  class Models::InsightsProbe
    attr_reader :id, :user_id, :user_plugin_id, :test_template_id, :uuid, :uuid_group, :type,
      :notification, :description, :description_link, :test, :base_object_locator, :preconditions, :conditionals,
      :object_key_locator, :security_architecture_weight, :cost_architecture_weight, :delivery_architecture_weight,
      :security_maintenance_weight, :cost_maintenance_weight, :delivery_maintenance_weight,
      :security_support_weight, :cost_support_weight, :delivery_support_weight,
      :active, :editable, :template_type, :cruncher_type, :status, :labels, :plugin_type, :plugin_category, :tags

    def initialize(attributes = {})
      @id = attributes.fetch('id')
      @user_id = attributes.fetch('user_id')
      @user_plugin_id = attributes.fetch('user_plugin_id')
      @test_template_id = attributes.fetch('test_template_id')
      @uuid = attributes.fetch('uuid')
      @uuid_group = attributes.fetch('uuid_group')
      @type = attributes.fetch('type')
      @notification = attributes.fetch('notification')
      @description = attributes.fetch('description')
      @description_link = attributes.fetch('description_link')
      @test = attributes.fetch('test')
      @base_object_locator = attributes.fetch('base_object_locator')
      @preconditions = attributes.fetch('preconditions')
      @conditionals = attributes.fetch('conditionals')
      @object_key_locator = attributes.fetch('object_key_locator')
      @security_architecture_weight = attributes.fetch('security_architecture_weight')
      @cost_architecture_weight = attributes.fetch('cost_architecture_weight')
      @delivery_architecture_weight = attributes.fetch('delivery_architecture_weight')
      @security_maintenance_weight = attributes.fetch('security_maintenance_weight')
      @cost_maintenance_weight = attributes.fetch('cost_maintenance_weight')
      @delivery_maintenance_weight = attributes.fetch('delivery_maintenance_weight')
      @security_support_weight = attributes.fetch('security_support_weight')
      @cost_support_weight = attributes.fetch('cost_support_weight')
      @delivery_support_weight = attributes.fetch('delivery_support_weight')
      @active = attributes.fetch('active')
      @editable = attributes.fetch('editable')
      @template_type = attributes.fetch('template_type')
      @cruncher_type = attributes.fetch('cruncher_type')
      @status = attributes.fetch('status')
      @labels = attributes.fetch('labels')
      @plugin_type = attributes.fetch('plugin_type')
      @plugin_category = attributes.fetch('plugin_category')
      @tags = attributes.fetch('tags')
    end
  end
end
