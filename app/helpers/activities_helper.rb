module ActivitiesHelper
  def activity_active_class(name)
    params[:action] == name ? 'active' : nil
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

  def tag_link(tag_name)
    "#{link_to(tag_name, users_path(:tag => tag_name))}".html_safe
  end

  def incoming_activity_description(activity_item)
    user = activity_item.user
    item = activity_item.item
    target = activity_item.target

    if activity_vote?(activity_item)
      "#{link_to(user.full_name, me_user_path(user))} vouched for <strong>#{tag_link(item.voteable.tag.name)}</strong>".html_safe
    else
      "#{link_to(user.full_name, me_user_path(user))} tagged #{current_user && current_user == target ? "you" : link_to(target.full_name, me_user_path(target)) } as <strong>#{tag_link(item.tag.name)}</strong>".html_safe
    end
  end

  def outgoing_activity_description(activity_item)
    target = activity_item.target
    item   = activity_item.item
    user = activity_item.user

    if activity_vote?(activity_item)
      "#{current_user && current_user == user ? "You" : link_to(user.full_name, me_user_path(user)) } vouched on #{link_to(target.full_name, me_user_path(target))} 's profile for <strong>#{tag_link(item.voteable.tag.name)}</strong>".html_safe
    else
      "#{current_user && current_user == user ? "You" : link_to(user.full_name, me_user_path(user)) } tagged #{link_to(target.full_name, me_user_path(target))} as <strong>#{tag_link(item.tag.name)}</strong>".html_safe
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
      tagger = users.pop
      "#{link_to(tagger.full_name, me_user_path(tagger))} tagged or vouched for #{who?(user)} so far.".html_safe
    elsif users.length == 2
      "#{users.map{|user| link_to(user.full_name, me_user_path(user))}.join(' and ')} tagged or vouched for #{who?(user)} so far.".html_safe
    else
      output = []
      user = users.pop
      output << link_to(user.full_name, me_user_path(user))
      user = users.pop
      output << link_to(user.full_name, me_user_path(user))
      output.join(', ').concat(" and #{users.length} other people tagged or vouched for #{who?(user)} so far.").html_safe
    end

  end

  def who?(user)
    ((current_user && current_user == user) ? "you" : link_to(user.full_name, me_user_path(user))).html_safe
  end
end
