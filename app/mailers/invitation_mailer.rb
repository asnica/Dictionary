class InvitationMailer < ApplicationMailer
  def invite(invitation)
    Rails.logger.info "mailer 進入成功"
    @invitation = invitation
    @inviter = invitation.inviter
    @signup_url = "http://18.183.245.160/signup?token=#{invitation.token}"

    mail(
      from: "sandbox@sandbox38146922860d4236b6ba2262d36d7ee2.mailgun.org",
      to: invitation.email,
      subject: "#{@inviter.name}さんから単語帳アプリへの招待が届いています。",
      content_type: "text/html"
    )
  end
end
