class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)


    if @user.save
      log_in(@user)
      UserMailer.welcome_email(@user).deliver_now

      redirect_to root_path, notice: "会員登録に成功しました！"
    else
      flash.now[:alert] = "会員登録に失敗しました。入力内容を確認してください。"

      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
