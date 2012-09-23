class UserMailer < ActionMailer::Base

  default from: "GiveBrand <no-reply@givebrand.com>"

  def welcome_email(user)
    @receiver = user
    mail(to: @receiver.email, subject: "Welcome to GiveBrand!")
  end

  def tag_email(tagger, tagged, tag_names)
    @tagger    = tagger
    @receiver  = tagged
    @tag_names = tag_names
    mail(to: @receiver.email, subject: "Tagged... You're it!")
  end

  def vote_email(voter, voted, tag_name)
    @voter    = voter
    @receiver = voted
    @tag_name = tag_name
    mail(to: @receiver.email, subject: "Someone vouched for you!")
  end

  def invitation_accepted_email(inviter, user)
    @receiver = inviter
    @user     = user
    mail(to: @receiver.email, subject: "Your invitation has been accepted!")
  end

  def endorse_email(endorsement)
    @endorsement = endorsement
    @receiver    = endorsement.user_tag.user
    @endorser    = endorsement.endorser
    mail(to: @receiver.email, subject: "You've received an endorsement!")
  end

  def new_follower_email(follower, user)
    @receiver = user
    @follower = follower
    mail(to: @receiver.email, subject: "Somebody's following you on GiveBrand!")
  end
end
