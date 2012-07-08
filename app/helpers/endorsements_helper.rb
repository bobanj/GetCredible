module EndorsementsHelper
  def load_user_tags(user)
    user.user_tags.includes(:tag).map { |ut| [ut.tag.name, ut.id] }
  end
end
