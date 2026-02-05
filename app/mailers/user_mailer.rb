class UserMailer < ApplicationMailer
  default from: "noreply@tango-app.com"

  def welcome_email(user)
    @user = user
    @confirmation_url = confirmation_url(@user.confirmation_token)
    mail(
      to: @user.email,
      subject: "単語帳の登録完了のお知らせ"
    )
  end

  private
  def confirmation_url(token)
    confirm_email_url(token: token)
  end
end
