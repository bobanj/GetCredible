#class Float
#  # 0.666666666 -> 66.7
#  def to_percentage
#    100 * (self * (10 ** 3)).round / (10 ** 3).to_f
#  end
#end

require 'redis/sorted_set'

class ScoreCalculator
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
      total_user_tags = tag.user_tags_count
      # Comment set_scale_range to toggle logaritmic score calculation
      scale_max = probability * total_user_tags + (1 - probability)
      base = scale_max ** 0.01
      scale_range = set_scale_range(scale_max, base)

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
        outgoing = Redis::Value.new("user_tag:#{user_tag_id}:outgoing").value rescue false
        if !incoming || !outgoing
          user_tag = UserTag.find_by_id user_tag_id unless user_tag
          user_tag.update_counters
          incoming = Redis::Value.new("user_tag:#{user_tag_id}:incoming").value
          outgoing = Redis::Value.new("user_tag:#{user_tag_id}:outgoing").value
        end

        weight = rank.to_f * total_user_tags.to_f * (incoming.to_f / (incoming.to_f + outgoing.to_f))

        weight = 1.to_f + weight if weight < 1
        if weight.infinite?
          break
          raise "Infinite Weight for #{user_tag_id}"
          return false
        end
        unless scale_range.empty?
          if weight > scale_max
            tag_scores[user_tag_id] = score_max
          else
            scale_range.each_with_index do |range, index|
              if range.cover?(weight)
                tag_scores[user_tag_id] = index
                break
              end
            end
          end
        else
          tag_scores[user_tag_id] = weight
        end
      end

    end

    puts (Time.now - start).to_s
  end

  private

  def set_scale_range(scale_max, base)
    scale_range = []
    (1..score_max).to_a.inject(scale_max) { |result, scale_element|
      scale_range << Range.new(result / base, result)
      result / base
    }
    pom = scale_range.last
    pom = pom.first < pom.last ? pom.first : pom.last
    scale_range << Range.new(0, pom)
    scale_range.reverse
  end

end
