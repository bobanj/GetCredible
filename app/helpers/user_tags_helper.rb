module UserTagsHelper

  def tags_summary(user, viewer=nil)
    user.user_tags.includes([:tag, :votes, :user, :last_voters, :tagger]).map do |user_tag|
      tag_summary(user_tag, user, viewer)
    end
  end

  def user_avatar_url(user, size = :thumb)
    if user.avatar.present?
      user.avatar_url(size)
    else
      "#{DOMAIN_URL}/assets/#{user.avatar_url(size)}"
    end
  end

  def tag_summary(user_tag, user, viewer)
    tag        = user_tag.tag
    tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")
    score = tag_scores.score(user_tag.id).round
    last_voters = user_tag.last_voters.all
    score = 1 if score == 0 || (score == 100 && last_voters.size == 1)
    {
      id: user_tag.id,
      name: tag.name,
      voted: viewer && viewer.votes.detect{|vote| vote.voteable_id == user_tag.id} ? true : false,
      tagged: user_tag.tagger == viewer,
      score: score,
      total: tag.user_tags_count,
      rank: tag_scores.revrank(user_tag.id) + 1,
      # TODO: eager load: last_voters
      voters: last_voters.map{ |voter|
        { :name => voter.name, avatar: user_avatar_url(voter, :small), url: me_user_path(voter) } },
      voters_count: user_tag.incoming.value
    }
  end

  def tag_cloud_summary(user)
    top_tags = user.user_tags.includes(:tag).inject({}) { |result, user_tag|
      tag_scores = Redis::SortedSet.new("tag:#{user_tag.tag_id}:scores")
      result[user_tag.tag.name] = tag_scores.score(user_tag.id)
      result
    }.sort_by {|k,v| -v}.first(5).map{|t| t[0]}

    skills = top_tags.map{ |t| "<span class='skill'>#{t}</span>" }

    if skills.present?
      "#{user.short_name}#{apostrophe(user.name)} brand is associated with #{skills.to_sentence}.".html_safe
    end
  end

  def preload_associations(activity_items)
    vote_activities        = activity_items.select{|i| i.item_type == 'Vote'}
    user_tag_activities    = activity_items.select{|i| i.item_type == 'UserTag'}
    endorsement_activities = activity_items.select{|i| i.item_type == 'Endorsement'}

    ActiveRecord::Associations::Preloader.
      new(vote_activities, [{:item => {:voteable => :tag}}, :target, :user]).run

    ActiveRecord::Associations::Preloader.
      new(user_tag_activities, [{:item => :tag}, :target, :user]).run

    ActiveRecord::Associations::Preloader.
      new(endorsement_activities, [{:item => :endorser}, :target, :user]).run
  end
end
