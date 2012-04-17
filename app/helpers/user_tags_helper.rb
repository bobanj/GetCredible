module UserTagsHelper

  def tags_summary(user, viewer=nil)
    user.user_tags.includes([:tag, :votes]).map do |user_tag|

      tag = user_tag.tag
      rank_index = tag.voted_ranking.index(user)

      {
        id: user_tag.id,
        name: tag.name,
        # voted: viewer && viewer.voted_for?(user_tag),
        voted: viewer && viewer.votes.detect { |vote| vote.voteable_id == user_tag.id },
        votes: user_tag.calculate_votes,
        # TODO: eager load: voted_ranking
        total: tag.voted_ranking.length,
        rank: rank_index ? rank_index + 1 : rank_index,
        # TODO: eager load: last_voters
        voters: user_tag.last_voters.map{ |voter|
          { :name => voter.full_name, avatar: user_avatar_url(voter, :small) } }
      }
    end
  end

  def user_avatar_url(user, size = :thumb)
    if user.avatar.present?
      user.avatar_url(size)
    else
      "#{DOMAIN_URL}/assets#{user.avatar_url(size)}"
    end
  end

end
