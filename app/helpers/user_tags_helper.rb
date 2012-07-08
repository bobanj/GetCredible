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
    score = 1 if score == 0
    {
      id: user_tag.id,
      name: tag.name,
      voted: viewer && viewer.votes.detect{|vote| vote.voteable_id == user_tag.id} ? true : false,
      tagged: user_tag.tagger == viewer,
      score: score,
      total: tag.user_tags_count,
      rank: tag_scores.revrank(user_tag.id) + 1,
      # TODO: eager load: last_voters
      voters: user_tag.last_voters.all.map{ |voter|
        { :name => voter.name, avatar: user_avatar_url(voter, :small) } },
      voters_count: user_tag.incoming.value
    }
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
