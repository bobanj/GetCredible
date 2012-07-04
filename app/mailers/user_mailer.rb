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

  def invitation_accepted_email(inviter, user)
    @inviter = inviter
    @user    = user
    mail(to: inviter.email, subject: "Your invitation has been accepted!")
  end

  def endorse_email(endorsement)
    @endorsement = endorsement
    @user        = endorsement.user_tag.user
    @endorser    = endorsement.endorser
    mail(to: @user.email, subject: "Your have been endorsed!")
  end
end
