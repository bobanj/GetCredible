#class Float
#  # 0.666666666 -> 66.7
#  def to_percentage
#    100 * (self * (10 ** 3)).round / (10 ** 3).to_f
#  end
#end

require 'redis/sorted_set'

class RankCalculator
  attr_accessor :probability, :tolerance, :score_max

  def initialize
    # The bigger the number, less probability
    # we have to teleport to some random link
    @probability = 0.85
    # the smaller the number, the more exact the
    # result will be but more CPU cycles will be needed
    @tolerance = 0.0001
    @score_max = 100
  end

  def calculate
    start = Time.now
    #ActiveRecord::Base.connection.execute('DELETE FROM "user_tag_results"')
    Tag.all.each do |tag|
      total_user_tags = tag.user_tags.count
      scale_max = probability * total_user_tags + (1 - probability)
      base = scale_max ** 0.01

      scale_range = []
      (1..score_max).to_a.inject(scale_max) { |result, scale_element|
        scale_range << Range.new(result / base, result)
        result / base
      }
      scale_range << Range.new(0, scale_range.last.min)
      scale_range.reverse!

      rankable_graph = RankableGraph.new
      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag.user_tags.includes(:votes => {:voter => :user_tags}).each do |user_tag|
        user_tag.votes.each do |vote|
          findit = vote.voter.user_tags.detect { |vut| vut.tag_id == user_tag.tag_id }
          if findit
            rankable_graph.link(findit.id, user_tag.id)
          end
        end
      end

      rankable_graph.rank(probability, tolerance) do |user_tag_id, rank|
        #user_tag = UserTag.find_by_id user_tag_id rescue nil
        # TODO set outgoing and incoming votes after vote:create so they only get here

        incoming = Redis::Value.new("user_tag:#{user_tag_id}:incoming").value rescue false
        unless incoming
          user_tag = UserTag.find_by_id user_tag_id
          incoming = calculate_incoming(user_tag)
          value = Redis::Value.new("user_tag:#{user_tag_id}:incoming")
          value.value = incoming
        end

        outgoing = Redis::Value.new("user_tag:#{user_tag_id}:outgoing").value rescue false
        unless outgoing
          user_tag = UserTag.find_by_id user_tag_id unless user_tag
          outgoing = calculate_outgoing(user_tag, tag)
          value = Redis::Value.new("user_tag:#{user_tag_id}:outgoing")
          value.value = outgoing
        end

        weight = rank.to_f * total_user_tags.to_f * (incoming.to_f / outgoing.to_f)
        weight = 1.to_f + weight if weight < 1
        if weight.infinite?
          raise "Infinite Weight for #{user_tag_id}"
          return false
        end
        if weight > scale_max
          tag_scores[user_tag_id] = score_max
          #puts "user_tag.id:#{user_tag.id}  rank: #{rank}  incoming: #{incoming}   outgoing: #{outgoing}    weight:#{weight}"
          #UserTagResult.create tag_id: user_tag.tag_id, user_id: user_tag.user_id, user_tag_id: user_tag.id, rank: rank, incoming: incoming, outgoing: outgoing, weight: weight, weight_index: index
        else
          scale_range.each_with_index do |range, index|
            if range.cover?(weight)
              tag_scores[user_tag_id] = weight
              #puts "user_tag.id:#{user_tag.id}  rank: #{rank}  incoming: #{incoming}   outgoing: #{outgoing}    weight:#{weight}  index: #{index}"
              #UserTagResult.create tag_id: user_tag.tag_id, user_id: user_tag.user_id, user_tag_id: user_tag.id, rank: rank, incoming: incoming, outgoing: outgoing, weight: weight, weight_index: index
              break
            end
          end
        end
      end

    end

    puts (Time.now - start).to_s
  end

  private

  def calculate_outgoing(user_tag, tag)
    user_tag.user.votes.joins({:user_tag => :tag}).where("tags.id = ?", tag.id).length
  end

  def calculate_incoming(user_tag)
    user_tag.votes.length
  end

end
