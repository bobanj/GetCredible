module UsersHelper

  def user_link(user)
    link_to(user.name, user_path(user))
  end

  def user_title(user)
    if user.active?
      title = link_to(user.name, user_path(user))
    else
      title = user.name
    end

    title += ", #{truncate(user.short_bio, length: 150)}" if user.short_bio.present?
    title
  end

  def twitter_name(user)
    if user.twitter_handle.present?
      "@#{user.twitter_handle} #{apostrophe(user.twitter_handle)}"
    else
      "#{user.name}#{apostrophe(user.name)}"
    end
  end

  def user_name_with_username(user)
    if user.full_name.present?
      "#{user.full_name} (#{user.username})"
    else
      user.username
    end
  end
end
