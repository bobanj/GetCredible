module ActivitiesHelper
  def activity_active_class(name)
    params[:id] == name ? 'active' : nil
  end

  def activity_class(activity_item)
    classes = []

    case activity_item.item
      when Vote
        classes << 'vouche'
      when UserTag
        classes << 'tag'
      when Endorsement
        classes << 'endorsement'
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
    "#{link_to(tag_name, users_path(:q => tag_name))}".html_safe
  end

  def user_link(user)
    "#{link_to(user.name, me_user_path(user))}".html_safe
  end

  def apostrophe(term)
    term =~ /s$/i ? "'" : "'s"
  end

  def user_long(user)
    user.name =~ /s$/i ? "#{user.name}'" : "#{user.name}'s"
  end

  def incoming_activity_description(activity_item)
    user = activity_item.user
    item = activity_item.item
    target = activity_item.target

    case item
      when Vote
        "Check YOU out! #{user_link(user)} vouched for your tag: #{tag_link(item.voteable.tag.name)}".html_safe
      when UserTag
        if user == target
          "Sweet! You tagged yourself: #{tag_link(item.tag.name)}".html_safe
        else
          "Sweet! #{user_link(user)} tagged #{current_user && current_user == target ? "you" : user_link(target) }: #{tag_link(item.tag.name)}".html_safe
        end
      when Endorsement
        "Cool! #{user_link(user)} endorsed #{current_user && current_user == target ? "you" : user_link(target) }".html_safe
    end
  end

  def outgoing_activity_description(activity_item)
    target = activity_item.target
    item   = activity_item.item
    user = activity_item.user

    case item
      when Vote
        "#{current_user && current_user == user ? "You" : link_to(user.name, me_user_path(user)) } vouched for #{user_link(target)}'s tag: #{tag_link(item.voteable.tag.name)}".html_safe
      when UserTag
        if user == target
          "#{user_link(user)} tagged themself: #{tag_link(item.tag.name)}".html_safe
        else
          "#{current_user && current_user == user ? "You" : user_link(user) } tagged #{user_link(target)}: #{tag_link(item.tag.name)}".html_safe
        end
      when Endorsement
        "#{current_user && current_user == user ? "You" : user_link(user) } wrote an endorsement for #{user_link(target)}".html_safe
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
      "#{link_to(tagger.name, me_user_path(tagger))} tagged or vouched for #{who?(user)} so far.".html_safe
    elsif users.length == 2
      "#{users.map{|user| link_to(user.name, me_user_path(user))}.join(' and ')} tagged or vouched for #{who?(user)} so far.".html_safe
    else
      output = []
      u = users.pop
      output << link_to(u.name, me_user_path(u))
      u = users.pop
      output << link_to(u.name, me_user_path(u))
      output.join(', ').concat(" and #{users.length} other people tagged or vouched for #{who?(user)} so far.").html_safe
    end

  end

  def who?(user)
    ((current_user && current_user == user) ? "you" : link_to(user.name, me_user_path(user))).html_safe
  end
end
