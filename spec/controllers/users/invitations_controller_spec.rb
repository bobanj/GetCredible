require 'spec_helper'

describe Users::InvitationsController do
  let(:user) { Factory(:user) }

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it "can invite user" do
    post :create, :user => {:email => "user@example.com"},
                  :user_id => user.slug, :format => 'json'

    response.should be_ok
    json = JSON.parse(response.body)
    json["success"].should be_true
    json["user"]["id"].should be_present
    json["user"]["email"].should == "user@example.com"
  end

  it "cannot invite user with invalid email" do
    post :create, :user => {:email => "invalid_email"}, :format => 'json'

    response.should be_ok
    json = JSON.parse(response.body)
    json["success"].should be_false
    json["errors"].should include("Email is invalid")
  end
end
