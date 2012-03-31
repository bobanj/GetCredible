module UsersHelper
  def disable_tagging(user)
    user == current_user || current_user.nil?
  end
end
