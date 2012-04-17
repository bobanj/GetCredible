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

  def class_for_activity(activity)
    case activity.item
      when Tag then "tag"
      when UserTag then "tag"
      when Vote then "vouch"
    end
  end
end
