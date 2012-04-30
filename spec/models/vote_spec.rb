require 'spec_helper'

describe Vote do
  let(:user) { Factory(:user) }
  let(:tagger) { Factory(:user) }
  let(:tag)  { Factory(:tag) }
  let(:user_tag){ Factory(:user_tag, tag: tag, user: user, tagger: tagger) }

  describe 'Associations' do
    it { should belong_to(:user_tag) }
    it { should belong_to(:voteable) }
    it { should have_many(:voted_users) }
  end

  describe 'Validations' do
    subject { Factory(:vote,  voteable: user_tag, voter: user) }
    it { should validate_presence_of(:voteable_id) }
    it { should validate_presence_of(:voter_id) }
    it { should validate_presence_of(:vote) }
  end

  describe 'Callbacks' do
    it 'Updates UserTag incoming and outgoing after create and destroy' do
      voter = Factory(:user)
      user_tag.votes.count.should == 0
      voter.add_vote(user_tag)
      user_tag.incoming.value.should == '1'
      user_tag.outgoing.value.should == '0'

      user_tag2 = Factory(:user_tag, tag: tag, user: voter, tagger: tagger)
      user.add_vote(user_tag2)
      user_tag.reload.outgoing.value.should == '1'
      user_tag.reload.incoming.value.should == '1'
      user_tag2.reload.outgoing.value.should == '1'
      user_tag2.reload.incoming.value.should == '1'

      voter.remove_vote(user_tag)
      user_tag.reload.outgoing.value.should == '1'
      user_tag.reload.incoming.value.should == '0'
      user_tag2.reload.outgoing.value.should == '0'
      user_tag2.reload.incoming.value.should == '1'

      user.remove_vote(user_tag2)
      user_tag.reload.outgoing.value.should == '0'
      user_tag.reload.incoming.value.should == '0'
      user_tag2.reload.outgoing.value.should == '0'
      user_tag2.reload.incoming.value.should == '0'
    end

  end

end
