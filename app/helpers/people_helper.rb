module PeopleHelper

  def people_active_class(name)
    params[:action] == name ? 'active' : nil
  end
end
