module UsersHelper
  def disable_tagging(user)
    user == current_user || current_user.nil?
  end

  def profile_title(user)
    if user.active?
      title = link_to(user.name, me_user_path(user))
    else
      title = user.name
    end

    title += ", #{user.short_bio}" if user.short_bio.present?
    title
  end

  def users_active_class(name)
    params[:action] == name ? 'active' : nil
  end
end
