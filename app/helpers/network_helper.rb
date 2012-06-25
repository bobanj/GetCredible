module NetworkHelper

  def network_active_class(name)
    params[:action] == name ? 'active' : nil
  end
end
