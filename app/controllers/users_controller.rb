class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:notice] = "会員登録に成功しました！"
      redirect_to signup_path
    else
      flash.now[:alert] = "会員登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
    
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end

