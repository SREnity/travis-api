module Travis::API::V3
  class Services::InsightsProbe::Update < Service
    params :test_template_id, :test, :plugin_type,
      :security_architecture_weight, :security_maintenance_weight, :security_support_weight,
      :cost_architecture_weight, :cost_maintenance_weight, :cost_support_weight,
      :delivery_architecture_weight, :delivery_maintenance_weight, :delivery_support_weight,
      :notification, :description, :description_link, :type, :labels, :tag_list
    result_type :insights_probe

    def run!
      raise LoginRequired unless access_control.full_access_or_logged_in?
      result query(:insights_probes).update(access_control.user.id)
    end
  end
end
