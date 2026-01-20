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
    it "shows system tags and own custom tags" do
      
    end

  end


  


  # describe "GET /index" do
  #   it "returns http success" do
  #     get "/word_tags/index"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe "GET /new" do
  #   it "returns http success" do
  #     get "/word_tags/new"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe "GET /create" do
  #   it "returns http success" do
  #     get "/word_tags/create"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe "GET /edit" do
  #   it "returns http success" do
  #     get "/word_tags/edit"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe "GET /update" do
  #   it "returns http success" do
  #     get "/word_tags/update"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # describe "GET /destroy" do
  #   it "returns http success" do
  #     get "/word_tags/destroy"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

end
