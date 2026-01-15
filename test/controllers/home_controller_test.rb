require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.create(
      name:"test user",
      email: "test@example.com",
      password: "password",
      password_confirmation: "password"
    )
  end

  test "should redirect to login when not logged in" do
    get root_path
    assert_redirected_to login_path
  end

  test "should get home page when logged in" do
    post login_path, params: {
      session: {
        email: "test@example.com",
        password: "password"
      }
    }

    get root_path
    assert_response :success
  end
  

end
