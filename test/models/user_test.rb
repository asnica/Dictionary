require "test_helper"

class UserTest < ActiveSupport::TestCase

  test "should be valid with valid attributes" do
    user = User.new(
      name: "Test User",
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert user.valid?, "User should be valid with valid attributes"

  end


 


end
