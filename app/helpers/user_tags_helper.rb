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
    {
      id: user_tag.id,
      name: tag.name,
      voted: viewer && viewer.votes.detect{|vote| vote.voteable_id = user_tag.id},
      tagged: user_tag.tagger == viewer,
      score: tag_scores.score(user_tag.id).round,
      # TODO: eager load: voted_ranking
      total: tag.user_tags_count,
      rank: tag_scores.revrank(user_tag.id) + 1,
      # TODO: eager load: last_voters
      voters: user_tag.last_voters.map{ |voter|
        { :name => voter.full_name, avatar: user_avatar_url(voter, :small) } },
      voters_count: user_tag.incoming.value
    }
  end
end
