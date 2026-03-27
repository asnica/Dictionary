class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @inviter = invitation.inviter
    @signup_url = new_user_url(token: invitation.token)

    mail(
      to: invitation.email,
      subject: "#{@inviter.name}さんから単語帳アプリへの招待が届いています。"
    )
  end
end
