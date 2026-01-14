require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  
    setup do 
        @user = User.create(
            name: "Test User",email: "test@example.com", password: "password123",password_confirmation: "password123"
        ) 
    end

    test "current_user returns nil when not logged in" do
        get signup_path
        assert_nil session[:user_id]
    end

    test "current_user returns user when logged in" do
        post login_path, params: {
            session: {
                email: @user.email,
                password: "password123"
            }
        }

        assert_equal @user.id, session[:user_id]
    end
    


end