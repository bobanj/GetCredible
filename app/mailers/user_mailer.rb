class UserMailer < ActionMailer::Base
  default from: "no-reply@givebrand.to"

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "[GiveBrand] Welcome")
  end

  def tag_email(tagger, tagged, tag_names)
    @tagger    = tagger
    @tagged    = tagged
    @tag_names = tag_names
    mail(to: tagged.email, subject: "[GiveBrand] You have been tagged!")
  end

  def vote_email(voter, voted, tag_name)
    @voter    = voter
    @voted    = voted
    @tag_name = tag_name
    mail(to: voted.email, subject: "[GiveBrand] You received a vote!")
  end
end
