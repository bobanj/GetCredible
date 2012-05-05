require 'spec_helper'

describe UserTagsHelper do
  let(:user) { Factory(:user) }
  let(:tagger) { Factory(:user) }

  describe "#tags_summary" do
    it "is empty when no user tags" do
      helper.tags_summary(user).should be_empty
    end

    it "sumarizes name and votes" do
      tagger.add_tags(user, ['web design'])
      tags = helper.tags_summary(user, nil)
      tags.length.should == 1
      tags[0][:id].should == user.user_tags[0].id
      tags[0][:name].should == "web design"
      # tags[0][:votes].should == 1
      tags[0][:voted].should be_false
    end

    it "sumarizes name and votes for a user" do
      tagger.add_tags(user, ['web design'])
      user_tag = user.user_tags[0]

      tagger.vote_exclusively_for(user_tag)

      tags = helper.tags_summary(user, tagger)
      tags.length.should == 1
      tags[0][:id].should == user.user_tags[0].id
      tags[0][:name].should == "web design"
      # tags[0][:votes].should == 1
      tags[0][:voted].should be_true
    end
  end
end
