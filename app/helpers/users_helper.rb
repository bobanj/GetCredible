module UsersHelper
  def disable_tagging(user)
    user == current_user || current_user.nil?
  end

  def profile_title(user)
    title = link_to(user.name, me_user_path(user))
    if user.job_title.present?
      title += ", #{user.job_title}"
    end
    title
  end
end
