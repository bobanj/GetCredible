require 'spec_helper'

describe 'User', type: :request do

  it "can endorse other users", js: true do
    reset_mailer

    endorser = FactoryGirl.create(:user, full_name: "Endorser")
    user = FactoryGirl.create(:user, full_name: "Pink Panter")
    sign_in_user(endorser)

    visit user_path(user)
    fill_in('token-input-tag_names', with: 'ruby, rails')
    click_button("Tag 'em!")

    visit user_path(user) # needed to receive email and then read it
    open_email(user.email)
    current_email.should have_subject("Tagged... You're it!")

    reset_mailer

    within(".add-endorsement") do
      select("ruby", from: "write_endorsement_user_tag_id")
      fill_in("write_endorsement_description", with: "Endorsement for my friend")
      click_button("Endorse")
    end

    page.should have_content("Endorsement for my friend")
    page.should have_content("Written by Endorser")

    open_email(user.email)
    current_email.should have_subject("You've received an endorsement!")
    current_email.body.should have_content("Endorser has just left an endorsement")
    current_email.body.should have_content("Endorsement for my friend")
  end
end
