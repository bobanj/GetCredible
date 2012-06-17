class TagCleaner

  def self.clean(tag_names)
    tags = []

    tag_names.to_s.split(',').each do |tag_name|
      tag_name = tag_name.gsub(/[^A-Za-z0-9\s]/, '').downcase.strip
      tags << tag_name unless tag_name.blank?
    end

    tags.uniq
  end
end
