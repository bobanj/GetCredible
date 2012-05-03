require 'spec_helper'

describe ActivitiesController do

  let(:user) { Factory(:user, full_name: 'User') }
  let(:activity_item) { stub('activity_item') }

  describe "Authentication" do
    it_should_require_current_user_for :show
  end

  describe "#show" do
    before :each do
      sign_in(user)
      user.stub_chain(:user_tags, :exists?).and_return(true)
      controller.stub(:current_user).and_return(user)
      controller.stub(:preload_associations)
    end

    it "can return all activities" do
      user.stub(:all_activities).and_return([activity_item])

      get :show, :id => 'all'
      assigns(:activity_items).should == [activity_item]
    end

    it "can return incoming activities" do
      user.stub_chain(:incoming_activities, :paginate).and_return([activity_item])

      get :show, :id => 'incoming'
      assigns(:activity_items).should == [activity_item]
    end

    it "can return outgoing activities" do
      user.stub_chain(:outgoing_activities, :paginate).and_return([activity_item])

      get :show, :id => 'outgoing'
      assigns(:activity_items).should == [activity_item]
    end

    it "raises exception when invalid id" do
      lambda {
        get :show, :id => 'invalid'
      }.should raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
