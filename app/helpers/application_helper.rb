module ApplicationHelper

  def flash_messages
    msg = ''
    flash.each do |key, value|
      msg << <<-EOF
        <div id="flash-message" style="display:none" data-type="#{key}">#{value}</div>
      EOF
    end
    msg.html_safe
  end

  # Creates unique id for HTML document body
  def controller_action_id
    parts = controller.controller_path.split('/')
    parts << controller.action_name
    parts.join('_')
  end

  def tag_cloud(user)
    content_tag(:div, '',
                :id => 'tag-cloud',
                "data-tag-cloud-path" => user_user_tags_path(@user),
                :"data-logged-in" => user_signed_in?.to_s,
                :"data-can-vote" => (!(user == current_user)).to_s,
                :"data-can-delete" => (@user == current_user).to_s,
                :"data-user" => {:first_name => @user.first_name,
                                 :last_name => @user.last_name,
                                 :full_name => @user.full_name}.to_json)


  end

  def class_for_activity(activity)
    case activity.item
      when Tag then "tag"
      when UserTag then "tag"
      when Vote then "vouch"
    end
  end
end
