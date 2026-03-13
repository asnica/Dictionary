class UserMailer < ApplicationMailer
  self.delivery_method = :letter_opener
  def welcome_email(user)
    @user = user
    mail(
      to: @user.email,
      subject: "新しいアカウントが作成されました",
      delivery_method_options: ActionMailer::Base.smtp_settings.merge(openssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
    )
  end
end
