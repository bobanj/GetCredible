module TagsHelper

  def tag_link(tag_name)
    link_to(tag_name, users_path(:q => tag_name))
  end
end
