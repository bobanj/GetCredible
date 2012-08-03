require 'spec_helper'

describe ScoreCalculator do
  let(:user1) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:user3) { FactoryGirl.create(:user) }
  let(:user4) { FactoryGirl.create(:user) }
  let(:user5) { FactoryGirl.create(:user) }
  let(:tagger) { FactoryGirl.create(:user) }
  let(:tag) { FactoryGirl.create(:tag, name: 'tag1') }
  let(:user_tag1) { FactoryGirl.create(:user_tag, tag: tag, user: user1, tagger: user1) }
  let(:user_tag2) { FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2) }
  let(:user_tag3) { FactoryGirl.create(:user_tag, tag: tag, user: user3, tagger: user3) }
  let(:user_tag4) { FactoryGirl.create(:user_tag, tag: tag, user: user4, tagger: user4) }
  let(:user_tag5) { FactoryGirl.create(:user_tag, tag: tag, user: user5, tagger: user5) }

  before :each do
    REDIS.del("tag:#{tag.id}:scores")
  end

  context "2 users" do
    it "user1 votes user2 - user1: 1, user2: 82" do
      # setup
      user_tag1
      user_tag2

      user1.add_vote(user_tag2)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == 1
      tag_scores.score(user_tag2.id).should == 82
    end

    it "user1 votes user2, user2 votes user1 - all have score: 66" do
      # setup
      user_tag1
      user_tag2

      user1.add_vote(user_tag2)
      user2.add_vote(user_tag1)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == 66
      tag_scores.score(user_tag2.id).should == 66
    end
  end

  context "3 users" do
    it "user1 votes user2, user2 votes user3, user3 votes user1 - all have score 41" do
      # setup
      user_tag1
      user_tag2
      user_tag3

      user1.add_vote(user_tag2)
      user2.add_vote(user_tag3)
      user3.add_vote(user_tag1)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == 41
      tag_scores.score(user_tag2.id).should == 41
      tag_scores.score(user_tag3.id).should == 41
    end

    it "user1 votes user3, user2 votes user3, user4 votes user1 - user1: 33, user2: 0, user3: 18, user4: 0" do
      # setup
      user_tag1
      user_tag2
      user_tag3
      user_tag4

      user1.add_vote(user_tag3)
      user2.add_vote(user_tag3)
      user4.add_vote(user_tag1)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      # weird results !?
      tag_scores.score(user_tag1.id).should == 33
      tag_scores.score(user_tag2.id).should == 0
      tag_scores.score(user_tag3.id).should == 18
      tag_scores.score(user_tag4.id).should == 0
    end

    it "user1 votes user3, user2 votes user3, user3 votes user4, user4 votes user1 - user1: 39, user2: 0, user3: 51, user4: 51" do
      # setup
      user_tag1
      user_tag2
      user_tag3
      user_tag4

      user1.add_vote(user_tag3)
      user2.add_vote(user_tag3)
      user3.add_vote(user_tag4)
      user4.add_vote(user_tag1)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == 39
      tag_scores.score(user_tag2.id).should == 0
      tag_scores.score(user_tag3.id).should == 51
      tag_scores.score(user_tag3.id).should == 51
    end
  end

  context "4 users" do
    it "user1 votes user2, user2 votes user3, user3 votes user4, user4 votes user1 - all have score 33" do
      # setup
      user_tag1
      user_tag2
      user_tag3
      user_tag4

      user1.add_vote(user_tag2)
      user2.add_vote(user_tag3)
      user3.add_vote(user_tag4)
      user4.add_vote(user_tag1)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == 33
      tag_scores.score(user_tag2.id).should == 33
      tag_scores.score(user_tag3.id).should == 33
      tag_scores.score(user_tag4.id).should == 33
    end

    it "user1 votes user4, user2 votes user4, user3 votes user4 - user1: 1, user2: 1, user3: 1, user4: 50" do
      # setup
      user_tag1
      user_tag2
      user_tag3
      user_tag4
      user_tag5

      user1.add_vote(user_tag4)
      user2.add_vote(user_tag4)
      user3.add_vote(user_tag4)
      user5.add_vote(user_tag4)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == 1
      tag_scores.score(user_tag2.id).should == 1
      tag_scores.score(user_tag3.id).should == 1
      tag_scores.score(user_tag4.id).should == 50
    end

    it "user1 votes user2, user1 votes user3, user1 votes user4, user1 votes user5, user2 votes user1, user2 votes user3 - user1: 13, user2: 18, user3: 42, user4: 25, user5: 25" do
      # setup
      user_tag1
      user_tag2
      user_tag3
      user_tag4
      user_tag5

      user1.add_vote(user_tag2)
      user1.add_vote(user_tag3)
      user1.add_vote(user_tag4)
      user1.add_vote(user_tag5)
      user2.add_vote(user_tag1)
      user2.add_vote(user_tag3)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == 13
      tag_scores.score(user_tag2.id).should == 18
      tag_scores.score(user_tag3.id).should == 42
      tag_scores.score(user_tag4.id).should == 25
      tag_scores.score(user_tag5.id).should == 25
    end
  end
end
