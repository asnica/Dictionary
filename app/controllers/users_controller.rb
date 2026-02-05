class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      UserMailer.welcome_email(@user).deliver_later
      flash[:notice] = "確認メールを送信しました。メールのリンクをクリックしてください。"
      redirect_to root_path
    else
      flash.now[:alert] = "会員登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def confirm_email
    user = User.find_by(confirmation_token: params[:token])

    if user&.confirm_email
      log_in(user)
      flash[:notice] = "メールアドレスが確認されました。ようこそ"
      redirect_to root_path
    else
      flash[:alert] = "無効な確認リンクです。"
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
