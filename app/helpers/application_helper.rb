module ApplicationHelper

  def flash_messages
    msg = ''
    flash.each do |key, value|
      msg << <<-EOF
        <div id="flash-#{key}" class="flash-message #{key}">#{value}</div>
      EOF
    end
    msg.html_safe
  end

end
