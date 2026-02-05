class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user&&user.authenticate(params[:session][:password])
      if user.email_confirmed?
        log_in(user)
        redirect_to root_path
      else
        flash[:alert] = "メールアドレスの確認をしてください"
        render :new
      end
    else
      flash[:alert] = "ログインに失敗しました"
      render :new, status: :unprocessable_entity

    end
  end

  def destroy
    session.delete(:user_id)
    @current_user = nil
    flash[:notice] = "ログアウトしました。"
    redirect_to login_path
  end
end
