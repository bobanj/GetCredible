class RankCalculator
  attr_accessor :rankable_graph, :probability,
                :tolerance, :users, :total_users

  def initialize
    @rankable_graph = RankableGraph.new

    # The bigger the number, less probability
    # we have to teleport to some random link
    @probability = 0.85

    # the smaller the number, the more exact the
    # result will be but more CPU cycles will be needed
    @tolerance = 0.0001

    # all users with linkings
    @users = User.includes(:voted_users)
    @total_users = @users.length
  end

  def calculate
    setup_linking

    rankable_graph.rank(probability, tolerance) do |user_id, rank|
      user = find_user_by_id(user_id)

      user.votes.each do |vote|
        user_tag = vote.user_tag
        tag      = user_tag.tag
        outgoing = calculate_outgoing(user, tag)
        incoming = calculate_incoming(user, tag)

        weight = (rank * total_users.to_f * (incoming.to_f / outgoing.to_f)).ceil
        weight = 1 if weight == 0

        # puts "name: #{user.full_name}; rank: #{rank}; tag: #{tag.name}; incoming: #{incoming}; outgoing: #{outgoing}; weight: #{weight}"
        vote.weight = weight
        vote.save(validate: false)
      end
    end

    puts "#{Time.now} rank calculated."
  end

  private
    def setup_linking
      users.each do |user|
        user.voted_users.each do |voted_user|
          rankable_graph.link(user.id, voted_user.id)
        end
      end
    end

    def calculate_outgoing(user, tag)
      user.votes.
        joins("INNER JOIN user_tags ON user_tags.id = votes.voteable_id AND votes.voteable_type = 'UserTag'").
        joins("INNER JOIN tags ON user_tags.tag_id = tags.id").
        where("tags.id = ?", tag.id).length
    end

    def calculate_incoming(user, tag)
      user_tag = user.user_tags.joins(:tag).where("tags.id = ?", tag.id).first
      user_tag ? user_tag.votes.length : 0
    end

    def find_user_by_id(user_id)
      users.detect { |user| user.id == user_id }
    end
end
