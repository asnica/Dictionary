require 'rails_helper'

RSpec.describe "WordTags", type: :request do

  let(:user){User.create(name:"Test", email: "test@example.com",password:"password123","password_confirmation":"password123")}
  let(:other_user){
    User.create(name:"Other", email: "other@example.com",
    password:"password123","password_confirmation":"password123")
  }

  let!(:system_tag){WordTag.create(name:"N5", category: "system", color:"#4CAF50")}
  
  let!(:user_tag){
    user.word_tags.create(name:"HARD", color: "#FF5722")

  }

  let!(:other_user_tag){other_user.word_tags.create(name:"EASY", color:"#2196F3")}

  before do
    post login_path, params: {
      session: {
        email: user.email,
        password: "password123"
      }
    }
  end

  describe "GET /word_tags" do
    it "returns success response" do
      get word_tags_path
      expect(response).to have_http_status(:success)

      
    end

    it "assigns @system_tags" do 
      get word_tags_path
      expect(assigns(:system_tags)).to include(system_tag)
    end

    it "assigns @suctom_tags with only user's tags" do
      get word_tags_path
      expect(assigns(:custom_tags)).to include(user_tag)
      expect(assigns(:custom_tags)).not_to include(other_user_tag)
    end
  end



  

end

