module Travis::API::V3
  class Renderer::InsightsNotification < ModelRenderer
    representation :standard, :id, :type, :active, :weight, :message, :plugin_name, :plugin_type, :category
    representation :minimal, :id, :type, :active, :weight
  end
end
