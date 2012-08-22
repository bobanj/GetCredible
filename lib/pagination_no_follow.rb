require 'will_paginate/view_helpers/action_view'

class PaginationNoFollow < WillPaginate::ActionView::LinkRenderer
  def rel_value(page)
    [super, 'nofollow'].compact.join(' ')
  end
end
