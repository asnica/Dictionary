class UserMailer < ApplicationMailer
  self.delivery_method = :letter_opener
  def welcome_email(user)
    @user = user
    mail(
      to: @user.email,
      subject: "新しいアカウントが作成されました"
    )
  end
end
