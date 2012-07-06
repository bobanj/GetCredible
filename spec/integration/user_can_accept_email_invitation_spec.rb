require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can accept email invitation", js: true do
    reset_mailer

    user = FactoryGirl.create(:user, full_name: "Some Name")
    sign_in_user(user)
    click_link("Invite")
    click_link("Invite by email")

    # invite user
    within("#js-email-invitation-form") do
      fill_in("Name", with: "Invited")
      fill_in("Email", with: "invited1@example.com")
      fill_in("First tag", with: "tag1")
      fill_in("Second tag", with: "tag2")
      click_button("Send Email")
    end
    page.should have_content('An invitation email has been sent to invited1@example.com.')

    click_link("Logout")

    # invited user
    open_email("invited1@example.com")
    visit_in_email('Accept invitation')

    within("#content") do
      page.should have_content("tag1")
      page.should have_content("tag2")
      #page.should have_content("Some Name")
      page.should have_xpath("//img[@title=\"Some Name\"]")
    end

    fill_in("Username", with: "new_user")
    fill_in("Password", with: "password")
    click_button("Save")
    page.should have_content("Your have joined GiveBrand!")

    # invited user
    open_email(user.email)
    current_email.should have_subject("Your invitation has been accepted!")
    current_email.body.should have_content("Great news! Invited has just accepted your invitation")
  end
end
