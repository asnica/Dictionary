require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get signuppath" do
    get signup_path
    assert_response :success
  end

  test "should assign a new user" do
    get signup_path
    assert_not_nil assigns(:user)
    assert_instance_of User, assigns(:user)
  end

  test "should create user with valid data" do
    assert_difference('User.count', 1) do
      post users_path, params: {user: {name: "test", email: "test@example.com", password: "password", password_confirmation: "password"}}
    end
  end

  test "should redirect to signup page after successful creation" do
        post users_path, params: {
          user: {
            name: "Test User",
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
  
  assert_redirected_to signup_path
  end

end
