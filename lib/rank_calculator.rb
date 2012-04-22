class Float
  # 0.666666666 -> 66.7
  def to_percentage
    100 * (self * (10 ** 3)).round / (10 ** 3).to_f
  end
end

class RankCalculator
  attr_accessor :rankable_graph, :probability,
                :tolerance, :user_tags

  def initialize
    @rankable_graph = nil

    # The bigger the number, less probability
    # we have to teleport to some random link
    @probability = 0.85
    # the smaller the number, the more exact the
    # result will be but more CPU cycles will be needed
    @tolerance = 0.0001

    # all users with linkings
    #@user_tags = UserTag.select("user_tags.id").where("user_tags.tag_id IN (SELECT user_tags.tag_id FROM user_tags INNER JOIN votes ON votes.voteable_id = user_tags.id)").all
    #@user_tags = UserTag.select("user_tags.id").where("user_tags.tag_id IN (SELECT user_tags.tag_id FROM user_tags INNER JOIN votes ON votes.voteable_id = user_tags.id)").all
  end

  def calculate
    #start = Time.now
    #ActiveRecord::Base.connection.execute('DELETE FROM "user_tag_results"')
    Tag.all.each do |tag|
      total_user_tags = tag.user_tags.count
      #scale_max = probability * total_user_tags + (1 - probability)
      #base = scale_max ** 0.01
      #scale_range = []
      #(1..100).to_a.inject(scale_max) { |result, scale_element|
      #  scale_range << Range.new(result / base, result)
      #  result / base
      #}
      #scale_range << Range.new(0, scale_range.last.min)
      #scale_range.reverse!

      rankable_graph = RankableGraph.new
      tag.user_tags.includes(:votes => {:voter => :user_tags}).each do |user_tag|
        user_tag.votes.each do |vote|
          findit = vote.voter.user_tags.detect { |vut| vut.tag_id == user_tag.tag_id }
          if findit
            rankable_graph.link(findit.id, user_tag.id)
          end
        end
      end

      rankable_graph.rank(probability, tolerance) do |user_tag_id, rank|
        user_tag = UserTag.find_by_id user_tag_id rescue nil
        if user_tag

          outgoing = calculate_outgoing(user_tag, tag)
          incoming = calculate_incoming(user_tag)

          weight = rank.to_f * total_user_tags.to_f * (incoming.to_f / outgoing.to_f)
          weight = 1 if weight == 0
          user_tag.weight = weight
          user_tag.save unless weight.infinite?
          #if weight > scale_max
          #  # Change if changing scale
          #  user_tag.weight = 100
          #  puts "user_tag.id:#{user_tag.id}  rank: #{rank}  incoming: #{incoming}   outgoing: #{outgoing}    weight:#{weight}"
          #  #UserTagResult.create tag_id: user_tag.tag_id, user_id: user_tag.user_id, user_tag_id: user_tag.id, rank: rank, incoming: incoming, outgoing: outgoing, weight: weight, weight_index: index
          #else
          #  scale_range.each_with_index do |range, index|
          #    if range.cover?(weight)
          #      user_tag.weight = index
          #      puts "user_tag.id:#{user_tag.id}  rank: #{rank}  incoming: #{incoming}   outgoing: #{outgoing}    weight:#{weight}  index: #{index}"
          #      #UserTagResult.create tag_id: user_tag.tag_id, user_id: user_tag.user_id, user_tag_id: user_tag.id, rank: rank, incoming: incoming, outgoing: outgoing, weight: weight, weight_index: index
          #      break
          #    end
          #  end
          #end
          #user_tag.save
        end
      end

    end

    #puts (Time.now - start).to_s
  end

  private

  def calculate_outgoing(user_tag, tag)
    user_tag.user.votes.joins({:user_tag => :tag}).where("tags.id = ?", tag.id).length
  end

  def calculate_incoming(user_tag)
    user_tag.votes.length
  end

end
