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

  context "comparing 2 users" do
    it "user1 votes user2, only user2 has the tag" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user_tag2 = FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2)

      user1.add_vote(user_tag2)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag2.id).should == 100
    end

    it "user1 votes user2, both have the tag" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user_tag1 = FactoryGirl.create(:user_tag, tag: tag, user: user1, tagger: user1)
      user_tag2 = FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2)

      user1.add_vote(user_tag2)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == 1
      tag_scores.score(user_tag2.id).should == 100
      tag_scores.score(user_tag2.id).should > tag_scores.score(user_tag1.id)
    end

    it "score is same for chained votes between each other" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user_tag1 = FactoryGirl.create(:user_tag, tag: tag, user: user1, tagger: user1)
      user_tag2 = FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2)

      user1.add_vote(user_tag2)
      user2.add_vote(user_tag1)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == tag_scores.score(user_tag2.id)
    end

    it "votes from not credible users weight equally" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user3 = FactoryGirl.create(:user)
      user4 = FactoryGirl.create(:user)
      user_tag1 = FactoryGirl.create(:user_tag, tag: tag, user: user1, tagger: user1)
      user_tag2 = FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2)

      user3.add_vote(user_tag1)
      user4.add_vote(user_tag2)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == tag_scores.score(user_tag2.id)
    end

    it "votes from credible users weight equally" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user3 = FactoryGirl.create(:user)
      user4 = FactoryGirl.create(:user)
      user_tag1 = FactoryGirl.create(:user_tag, tag: tag, user: user1, tagger: user1)
      user_tag2 = FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2)
      user_tag3 = FactoryGirl.create(:user_tag, tag: tag, user: user3, tagger: user3)
      user_tag4 = FactoryGirl.create(:user_tag, tag: tag, user: user4, tagger: user4)

      user3.add_vote(user_tag1)
      user4.add_vote(user_tag2)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == tag_scores.score(user_tag2.id)
    end

    it "votes from credible users weight more than non credible" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user3 = FactoryGirl.create(:user)
      user4 = FactoryGirl.create(:user)
      user_tag1 = FactoryGirl.create(:user_tag, tag: tag, user: user1, tagger: user1)
      user_tag2 = FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2)
      user_tag3 = FactoryGirl.create(:user_tag, tag: tag, user: user3, tagger: user3)

      user3.add_vote(user_tag1)
      user4.add_vote(user_tag2)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should > tag_scores.score(user_tag2.id)
    end
  end

  context "comparing 3 users" do
    it "score is same for chained votes between each other" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user3 = FactoryGirl.create(:user)
      user_tag1 = FactoryGirl.create(:user_tag, tag: tag, user: user1, tagger: user1)
      user_tag2 = FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2)
      user_tag3 = FactoryGirl.create(:user_tag, tag: tag, user: user3, tagger: user3)

      user1.add_vote(user_tag2)
      user2.add_vote(user_tag3)
      user3.add_vote(user_tag1)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == tag_scores.score(user_tag2.id)
      tag_scores.score(user_tag1.id).should == tag_scores.score(user_tag3.id)
    end

    it "does not give everything earned" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user3 = FactoryGirl.create(:user)
      user_tag1 = FactoryGirl.create(:user_tag, tag: tag, user: user1, tagger: user1)
      user_tag2 = FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2)
      user_tag3 = FactoryGirl.create(:user_tag, tag: tag, user: user3, tagger: user3)

      user1.add_vote(user_tag3)
      user2.add_vote(user_tag3)
      user3.add_vote(user_tag2)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag3.id).should > tag_scores.score(user_tag1.id)
      tag_scores.score(user_tag3.id).should > tag_scores.score(user_tag2.id)
      tag_scores.score(user_tag2.id).should > tag_scores.score(user_tag1.id)
    end
  end

  context "comparing 4 users" do
    it "score is same for chained votes between each other" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user3 = FactoryGirl.create(:user)
      user4 = FactoryGirl.create(:user)
      user_tag1 = FactoryGirl.create(:user_tag, tag: tag, user: user1, tagger: user1)
      user_tag2 = FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2)
      user_tag3 = FactoryGirl.create(:user_tag, tag: tag, user: user3, tagger: user3)
      user_tag4 = FactoryGirl.create(:user_tag, tag: tag, user: user4, tagger: user4)

      user1.add_vote(user_tag2)
      user2.add_vote(user_tag3)
      user3.add_vote(user_tag4)
      user4.add_vote(user_tag1)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag1.id).should == tag_scores.score(user_tag2.id)
      tag_scores.score(user_tag1.id).should == tag_scores.score(user_tag3.id)
      tag_scores.score(user_tag1.id).should == tag_scores.score(user_tag4.id)
    end

    it "does not give everything earned" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user3 = FactoryGirl.create(:user)
      user4 = FactoryGirl.create(:user)
      user_tag1 = FactoryGirl.create(:user_tag, tag: tag, user: user1, tagger: user1)
      user_tag2 = FactoryGirl.create(:user_tag, tag: tag, user: user2, tagger: user2)
      user_tag3 = FactoryGirl.create(:user_tag, tag: tag, user: user3, tagger: user3)
      user_tag4 = FactoryGirl.create(:user_tag, tag: tag, user: user4, tagger: user4)

      user1.add_vote(user_tag3)
      user2.add_vote(user_tag3)
      user3.add_vote(user_tag4)
      user4.add_vote(user_tag1)

      rank_calculator = ScoreCalculator.new
      rank_calculator.calculate

      tag_scores = Redis::SortedSet.new("tag:#{tag.id}:scores")

      tag_scores.score(user_tag3.id).should > tag_scores.score(user_tag4.id)
      tag_scores.score(user_tag3.id).should > tag_scores.score(user_tag1.id)

      tag_scores.score(user_tag4.id).should > tag_scores.score(user_tag1.id)
    end
  end
end
