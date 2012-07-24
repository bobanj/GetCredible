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

  def twitter_name(user)
    if user.twitter_handle.present?
      "@#{user.twitter_handle} #{apostrophe(user.twitter_handle)}"
    else
      "#{user.name}#{apostrophe(user.name)}"
    end
  end

  def page_title(user)
    if user.full_name.present?
      "#{user.full_name} (#{user.username}) on Givebrand"
    else
      "#{user.username} on Givebrand"
    end
  end
end
