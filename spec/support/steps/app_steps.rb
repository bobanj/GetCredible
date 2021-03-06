def sign_in_user(user)
  visit root_path
  within("#user_sign_in") do
    fill_in("Email", with: user.email)
    fill_in("Password", with: user.password)
    click_button("Sign in")
  end
  page.should have_content("Logout")
end

def mock_send_message
  message_sender = mock
  GiveBrand::MessageSender.should_receive(:new).and_return(message_sender)
  message_sender.should_receive(:send_message).and_return(true)
end
