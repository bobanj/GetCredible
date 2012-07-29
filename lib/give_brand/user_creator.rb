module GiveBrand
  class UserCreator

    attr_accessor :invitation_message, :contact
    delegate :inviter, :provider, :tag_names, to: :invitation_message

    def initialize(invitation_message, contact)
      @invitation_message = invitation_message
      @contact            = contact
    end

    def create
      user = User.find_by_email(fake_email)

      unless user
        avatar = get_avatar_url(contact)
        user = User.new(email: fake_email, full_name: contact.name,
                        remote_avatar_url: avatar)
        user.invited_by = inviter
        user.skip_invitation = true
        user.invite!
      end

      inviter.add_tags(user, TagCleaner.clean(tag_names.join(',')), skip_email: true)
      inviter.follow(user)

      return user
    end

    private
    def get_avatar_url(contact)
      if provider == 'twitter'
        # replace the last '_normal' with ''
        contact.avatar.to_s.reverse.sub('_normal'.reverse, '').reverse
      end
    end

    def fake_email
      # devise saves email with downcase
      @fake_email ||= "#{provider}_#{contact.uid}".downcase
    end
  end
end

