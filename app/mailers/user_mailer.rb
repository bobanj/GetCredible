class UserMailer < ActionMailer::Base

  default from: "GiveBrand <no-reply@givebrand.to>"

  def welcome_email(user)
    @user = user
    mail(to: user.email, subject: "Welcome to GiveBrand!")
  end

  def tag_email(tagger, tagged, tag_names)
    @tagger    = tagger
    @tagged    = tagged
    @tag_names = tag_names
    mail(to: tagged.email, subject: "Tagged... You're it!")
  end

  def vote_email(voter, voted, tag_name)
    @voter    = voter
    @voted    = voted
    @tag_name = tag_name
    mail(to: voted.email, subject: "You received a vote!")
  end
end
