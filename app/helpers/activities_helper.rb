module ActivitiesHelper
  def activity_active_class(name)
    params[:id] == name ? 'active' : nil
  end

  def activity_class(activity_item)
    classes = ['you']

    if activity_vote?(activity_item)
      classes << 'vouche'
    else
      classes << 'tag'
    end

    #classes << 'you' if outgoing_activity?(activity_item)

    classes.join(' ')
  end

  def activity_description(activity_item)
    if outgoing_activity?(activity_item)
      outgoing_activity_description(activity_item)
    else
      incoming_activity_description(activity_item)
    end
  end

  def incoming_activity_description(activity_item)
    user = activity_item.user
    item = activity_item.item

    if activity_vote?(activity_item)
      "#{link_to(user.full_name, user)} vouched for <strong>#{item.voteable.tag.name}</strong>".html_safe
    else
      "#{link_to(user.full_name, user)} tagged you as <strong>#{item.tag.name}</strong>".html_safe
    end
  end

  def outgoing_activity_description(activity_item)
    target = activity_item.target
    item   = activity_item.item

    if activity_vote?(activity_item)
      "You vouched on #{link_to(target.full_name, target)} 's profile for<strong>#{item.voteable.tag.name}</strong>".html_safe
    else
      "You tagged #{link_to(target.full_name, target)} as <strong>#{item.tag.name}</strong>".html_safe
    end
  end

  def activity_vote?(activity_item)
    activity_item.item.is_a?(Vote)
  end

  def outgoing_activity?(activity_item)
    activity_item.target != current_user
  end
end
