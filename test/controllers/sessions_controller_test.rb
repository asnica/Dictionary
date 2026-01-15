require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.create!(name: "Test", email: "test@example.com", password: "password123", password_confirmation: "password123")
  end

  test "should get new" do
    get login_path
    assert_response :success
  end

  test "should not login with wrong password" do 
    post login_path, params: {
      session: {
        email: "test@example.com",
        password: "wrongpassword"
      }
    }

    assert_nil session[:user_id]
  end


  # test "should redirect after successful login" do
  #   post login_path, params: {
  #     session: {
  #       email: "test@example.com",
  #       password: "password123"

  #     }
  #   }
  #   assert_redirected_to root_path
  #   follow_redirect!
  #   assert_select "div.notice", "ようこそ！ 単語帳アプリへ。"
  # end


  test "should set flash notice on successful login" do
    post login_path, params: {
      session: {
        email: "test@example.com",
        password: "password123"
      }
    }

    assert_not_nil flash[:notice]
    assert_equal "ログインに成功しました！", flash[:notice]

  end

  test "should not render login page with wrong password" do
    post login_path, params: {
      session: {
        email: "text@example.com",
        password: "wrongpassword"
      }
    }
    assert_response :unprocessable_entity
    assert_template :new
  end


  test "should not logout user" do
    post login_path, params: {
      session: {
        email: "test@example.com",
        password: "password123"
      }
    }
    assert_equal @user.id, session[:user_id]

    delete logout_path
    assert_nil session[:user_id]
  end
  

      





end
