# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user/Welcome_email
  def Welcome_email
    UserMailer.Welcome_email
  end

end
