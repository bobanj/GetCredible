module ActivitiesHelper
  def activity_tab_class(name)
    params[:id] == name ? 'active' : nil
  end

  def activity_item_class(activity_item)
    outgoing_activity?(activity_item) ? 'you' : nil
  end

  def activity_description(activity_item)
    if outgoing_activity?(activity_item)
      outgoing_activity_description(activity_item)
    else
      incoming_activity_description(activity_item)
    end
  end

  def apostrophe(term)
    term =~ /s$/i ? "'" : "'s"
  end

  def incoming_activity_description(activity_item)
    user = activity_item.user
    target = activity_item.target
    subject_link = subject_link(user)
    object_link = object_link(target)

    case activity_item.item_type
    when 'Vote'
      "Check YOU out! #{subject_link} vouched for you"
    when 'UserTag'
      if user == activity_item.target
        "Sweet! You tagged yourself"
      else
        "Sweet! #{subject_link} tagged #{object_link}"
      end
    when 'Endorsement'
      "Cool! #{subject_link} endorsed #{object_link}"
    when 'Link'
      "#{subject_link} shared a #{link_to('link', activity_item.item.url, target: '_blank')}"
    end.html_safe
  end

  def outgoing_activity_description(activity_item)
    user = activity_item.user
    target = activity_item.target
    subject_link = subject_link(user)
    object_link = object_link(target)

    case activity_item.item_type
    when 'Vote'
      "#{subject_link} vouched for #{object_link}'s"
    when 'UserTag'
      if user == activity_item.target
        "#{user_link(user)} tagged themself"
      else
        "#{subject_link} tagged #{object_link}"
      end
    when 'Endorsement'
      "#{subject_link} wrote an endorsement for #{object_link}"
    when 'Link'
      "#{subject_link} shared a #{link_to('link', activity_item.item.url, target: '_blank')}"
    end.html_safe
  end

  private
  def outgoing_activity?(activity_item)
    activity_item.target != current_user
  end

  def subject_link(user)
    current_user && current_user == user ? "You" : user_link(user)
  end

  def object_link(target)
    current_user && current_user == target ? "you" : user_link(target)
  end
end
