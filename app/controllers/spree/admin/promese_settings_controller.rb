class Spree::Admin::PromeseSettingsController < Spree::Admin::ResourceController

  def index
    redirect_to edit_admin_promese_setting_path(model_class.instance.id)
  end

  def model_class
    @model_class ||= ::PromeseSetting
  end

end
