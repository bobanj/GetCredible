class TagCleaner

  def self.clean(tag_names)
    tags = []

    tag_names.to_s.split(',').each do |tag_name|
      tags << tag_name.gsub(/[^A-Za-z\s]/, '').downcase.strip
    end

    tags.uniq
  end
end
