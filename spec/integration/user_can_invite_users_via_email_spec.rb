require 'spec_helper'

describe 'User', type: :request do

  it "can invite users via email", js: true do
    reset_mailer

    user = FactoryGirl.create(:user, full_name: "Some Name")
    sign_in_user(user)
    click_link("Invite")
    # click_link("Invite by email")

    # see error messages
    within("#js-email-invitation-form") do
      click_button("Send Email")
      page.should have_content("can't be blank")
      page.should have_content("add at least one tag")
    end
    page.should have_content('We could not sent your email at this time.')

    # invite user
    within("#js-email-invitation-form") do
      fill_in("Name", with: "Invited 1")
      fill_in("Email", with: "invited1@example.com")
      fill_in("First tag", with: "tag1")
      fill_in("Second tag", with: "tag2")
      click_button("Send Email")
    end
    page.should have_content('An invitation email has been sent to invited1@example.com.')

    invited1 = User.find_by_email('invited1@example.com')
    user.followings.should include(invited1)

    unread_emails_for(invited1.email).size.should == parse_email_count(1)
    open_email(invited1.email)
    current_email.should have_subject("You are invited to GiveBrand!")
    current_email.body.should have_content("#{user.name} has tagged you with \"tag1\", \"tag2\" invited you to join GiveBrand")


    find_field("Email").value.should be_blank
    find_field("First tag").value.should be_blank

    # invite another user
    within("#js-email-invitation-form") do
      fill_in("Name", with: "Invited 2")
      fill_in("Email", with: "invited2@example.com")
      fill_in("First tag", with: "tag1")
      fill_in("Second tag", with: "tag2")
      click_button("Send Email")
    end
    page.should have_content('An invitation email has been sent to invited2@example.com.')

    invited2 = User.find_by_email('invited2@example.com')
    user.reload.followings.should include(invited2)
    unread_emails_for(invited2.email).size.should == parse_email_count(1)
    open_email(invited2.email)
    current_email.should have_subject("You are invited to GiveBrand!")
    current_email.body.should have_content("#{user.name} has tagged you with \"tag1\", \"tag2\" invited you to join GiveBrand")

    find_field("Name").value.should be_blank
    find_field("Email").value.should be_blank
    find_field("First tag").value.should be_blank
  end
end
