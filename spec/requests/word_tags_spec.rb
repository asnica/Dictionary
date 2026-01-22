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



  #authorization 

  describe "Get /word_tags/:id/edit" do
    context "when editing a system tag" do
      it "redirect with alert" do
        get edit_word_tag_path(system_tag)
        expect(response).to redirect_to(word_tags_path)
        follow_redirect!
        expect(response.body).to include("システムタグは変更できません。")
      end
    end

    context "when editing other user's tag" do
      it "redirects with alert" do
        get edit_word_tag_path(other_user_tag)
        expect(response).to redirect_to (word_tags_path)
        follow_redirect!
        expect(response.body).to include("他のユーザーのタグは変更できません。")
      end
    end

    context "when editing own tag" do
      it "returns success" do 
        get edit_word_tag_path(user_tag)
        expect(response).to have_http_status(:success)
      end
    end
    

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


