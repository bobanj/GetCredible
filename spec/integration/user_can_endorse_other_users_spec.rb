require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can endorse other users", js: true do
    reset_mailer

    endorser = FactoryGirl.create(:user, full_name: "Endorser")
    user = FactoryGirl.create(:user, full_name: "Pink Panter")
    sign_in_user(endorser)

    visit me_user_path(user)
    fill_in('token-input-tag_names', with: 'ruby, rails')
    click_button("Tag 'em!")


    visit me_user_path(user) # needed to receive email and then read it
    open_email(user.email)
    current_email.should have_subject("Tagged... You're it!")

    reset_mailer
    click_link("Endorse this tag")
    fill_in("endorsement_description", with: "Endorsement for my friend")
    click_button("Endorse")
    page.should have_content("Endorsement for my friend")
    page.should have_content("Written by Endorser less than a minute")

    open_email(user.email)
    current_email.should have_subject("Your have been endorsed!")
    current_email.body.should have_content("Great news: Endorser has endorsed you")
    current_email.body.should have_content("Endorsement for my friend")
  end
end
