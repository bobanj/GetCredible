module UsersHelper
  def disable_tagging(user)
    user == current_user || current_user.nil?
  end

  def top_tags(user)
    user.top_tags(3).map { |tag| tag[:name] }
  end
end
