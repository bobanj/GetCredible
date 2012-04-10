def sign_in_user(user)
  visit root_path
  click_link("Login")
  fill_in("Email", with: user.email)
  fill_in("Password", with: user.password)
  click_button("Sign in")
  page.should have_content("Signed in successfully.")
end
