module Travis::API::V3
  class Renderer::InsightsProbe < ModelRenderer
    representation :standard, :id, :user_id, :user_plugin_id, :test_template_id, :uuid, :uuid_group, :type,
      :notification, :description, :description_link, :test, :base_object_locator, :preconditions, :conditionals,
      :object_key_locator, :security_architecture_weight, :cost_architecture_weight, :delivery_architecture_weight,
      :security_maintenance_weight, :cost_maintenance_weight, :delivery_maintenance_weight,
      :security_support_weight, :cost_support_weight, :delivery_support_weight,
      :active, :editable, :template_type, :cruncher_type, :status, :labels, :plugin_type, :plugin_type_name, :plugin_category, :tag_list
    representation :minimal, :id, :type, :plugin_type, :plugin_type_name, :plugin_category, :label, :notification, :status, :tag_list
  end
end
