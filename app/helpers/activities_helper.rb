module ActivitiesHelper
  def activity_active_class(name)
    params[:id] == name ? 'active' : nil
  end

  def activity_class(activity_item)
    classes = []

    if activity_vote?(activity_item)
      classes << 'vouche'
    else
      classes << 'tag'
    end

    classes << 'you' if outgoing_activity?(activity_item)

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
      "#{link_to(user.full_name, user)} tagged #{current_user ? "you" : activity_item.target.full_name } as <strong>#{item.tag.name}</strong>".html_safe
    end
  end

  def outgoing_activity_description(activity_item)
    target = activity_item.target
    item   = activity_item.item

    if activity_vote?(activity_item)
      "#{current_user ? "You" : activity_item.user.full_name } vouched on #{link_to(target.full_name, target)} 's profile for<strong>#{item.voteable.tag.name}</strong>".html_safe
    else
      "#{current_user ? "You" : activity_item.user.full_name } tagged #{link_to(target.full_name, target)} as <strong>#{item.tag.name}</strong>".html_safe
    end
  end

  def activity_vote?(activity_item)
    activity_item.item.is_a?(Vote)
  end

  def outgoing_activity?(activity_item)
    activity_item.target != current_user
  end

  def tag_cloud_summary(user)
    users = user.incoming_activities.includes(:user).map{|a| a.user}.uniq

    if users.length == 0
      "Nobody tagged or vouched you so far."
    elsif users.length == 1
      user = users.pop
      "#{link_to(user.full_name, user)} tagged or vouched you so far.".html_safe
    elsif users.length == 2
      "#{users.map{|user| link_to(user.full_name, user)}.join(' and ')} tagged or vouched you so far.".html_safe
    else
      output = []
      user = users.pop
      output << link_to(user.full_name, user)
      user = users.pop
      output << link_to(user.full_name, user)
      output.join(', ').concat(" and #{users.length} other people tagged or vouched you so far.").html_safe
    end

  end
end
