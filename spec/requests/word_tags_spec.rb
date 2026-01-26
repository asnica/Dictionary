require 'rails_helper'

RSpec.describe "WordTags", type: :request do
  let(:user) { User.create(name: "Test", email: "test@example.com", password: "password123", "password_confirmation": "password123") }
  let(:other_user) {
    User.create(name: "Other", email: "other@example.com",
    password: "password123", "password_confirmation": "password123")
  }



  let!(:system_tag) { WordTag.create(name: "N5", category: "system", color: "#4CAF50") }


  let!(:user_tag) {
    user.word_tags.create(name: "感情", color: "#FF5722")
  }

  let!(:other_user_tag) { other_user.word_tags.create(name: "EASY", color: "#2196F3") }

  before do
    post login_path, params: {
      session: {
        email: user.email,
        password: "password123"
      }
    }
  end

  # INDEX (목록 + 검색)
  describe "GET /word_tags" do
    it "returns success" do
      get word_tags_path
      expect(response).to have_http_status(:success)
    end

    it "assigns @system_tags" do
      get word_tags_path
      expect(assigns(:system_tags)).to include(system_tag)
    end

    it "assigns only user's custom tags to @custom_tags" do
      get word_tags_path
      expect(assigns(:custom_tags)).to include(user_tag)
      expect(assigns(:custom_tags)).not_to include(other_user_tag)
    end

    context "with search query" do
      let!(:tag1) { user.word_tags.create!(name: "日本語N5", color: "#4CAF50") }
      let!(:tag2) { user.word_tags.create!(name: "日本語N4", color: "#8BC34A") }
      let!(:tag3) { user.word_tags.create!(name: "英語単語", color: "#2196F3") }

      it "searches by name (partial match)" do
        get word_tags_path, params: { search: "日本語" }

        expect(assigns(:custom_tags)).to include(tag1, tag2)
        expect(assigns(:custom_tags)).not_to include(tag3)
      end

      it "returns empty when no match" do
        get word_tags_path, params: { search: "存在しない" }

        expect(assigns(:custom_tags)).to be_empty
      end
    end
  end


  describe "GET /word_tags/new" do
    it "returns success" do
      get new_word_tag_path
      expect(response).to have_http_status(:success)
    end

    it "assigns new WordTag to @word_tag" do
      get new_word_tag_path
      expect(assigns(:word_tag)).to be_a_new(WordTag)
    end
  end


  describe "POST /word_tags" do
    context "with valid parameters" do
      it "creates a new tag" do
        expect {
          post word_tags_path, params: {
            word_tag: {
              name: "試験対策",
              description: "試験用の単語",
              color: "#9C27B0"
            }
          }
        }.to change(WordTag, :count).by(1)
      end

      it "assigns tag to current user" do
        post word_tags_path, params: {
          word_tag: {
            name: "試験対策",
            color: "#9C27B0"
          }
        }

        tag = WordTag.last
        expect(tag.user).to eq(user)
        expect(tag.category).to eq("custom")
      end

      it "redirects to index with notice" do
        post word_tags_path, params: {
          word_tag: {
            name: "試験対策",
            color: "#9C27B0"
          }
        }

        expect(response).to redirect_to(word_tags_path)
        follow_redirect!
        expect(response.body).to include("タグが作成されました。")
      end
    end
    context "with invalid parameters" do
      it "does not create a new tag" do
        expect {
          post word_tags_path, params: {
            word_tag: {
              name: "",
              color: "#9C27B0"
            }
          }
        }.not_to change(WordTag, :count)
      end
      it "renders new template with unprocessable_entity status" do
        post word_tags_path, params: {
          word_tag: { name: "" }
        }

        expect(response).to have_http_status(422)
        expect(response.body).to include("登録に失敗しました。")
      end
    end
    context "with duplicate name for the same user" do
      it "does not create a new tag" do
        expect {
          post word_tags_path, params: {
            word_tag: {
              name: "感情",
              color: "#FF5722"
            }
          }
        }.not_to change(WordTag, :count)
      end
    end
  end
  describe "GET /word_tags/id/edit" do
    context "when editing own tag" do
      it "returns success" do
        get edit_word_tag_path(user_tag)
        expect(response).to have_http_status(:success)
      end
      it "assigns the tag to @word_tag" do
        get edit_word_tag_path(user_tag)
        expect(assigns(:word_tag)).to eq(user_tag)
      end
    end
    context "when trying to edit system tag" do
      it "redirects with alert" do
        get edit_word_tag_path(system_tag)
        expect(response).to redirect_to(word_tags_path)
        follow_redirect!
        expect(response.body).to include("システムタグは変更できません。")
      end
    end
    context "when trying to edit another user's tag" do
      it "redirects with alert" do
        get edit_word_tag_path(other_user_tag)
        expect(response).to redirect_to(word_tags_path)
        follow_redirect!
        expect(response.body).to include("他のユーザーのタグは変更できません。")
      end
    end
  end
  describe "PATCH /word_tags/id" do
    context "with valid params" do
      it "updates the tag" do
        patch word_tag_path(user_tag), params: {
          word_tag: {
            name: "とても難しい単語", description: "更新しました"
          }
        }
        user_tag.reload
        expect(user_tag.name).to eq("とても難しい単語")
        expect(user_tag.description).to eq("更新しました")
      end
      it "redirects to index with notice" do
        patch word_tag_path(user_tag), params: {
          word_tag: { name: "更新済みタグ" }
        }
        expect(response).to redirect_to(word_tags_path)
        follow_redirect!
        expect(response.body).to include("タグが更新されました。")
      end
    end
  end
  describe "DELETE /word_tags/:id" do
    it "deletes the tag" do
      expect {
        delete word_tag_path(user_tag)
      }.to change(WordTag, :count).by(-1)
    end

    it "redirects to index with notice" do
      delete word_tag_path(user_tag)

      expect(response).to redirect_to(word_tags_path)
      follow_redirect!
      expect(response.body).to include("タグが削除されました。")
    end

    context "when trying to delete system tag" do
      it "does not delete" do
        expect {
          delete word_tag_path(system_tag)
        }.not_to change(WordTag, :count)
      end

      it "redirects with alert" do
        delete word_tag_path(system_tag)

        expect(response).to redirect_to(word_tags_path)
        follow_redirect!
        expect(response.body).to include("システムタグは変更できません。")
      end
    end

    context "when trying to delete other user's tag" do
      it "does not delete" do
        expect {
          delete word_tag_path(other_user_tag)
        }.not_to change(WordTag, :count)
      end

      it "redirects with alert" do
        delete word_tag_path(other_user_tag)

        expect(response).to redirect_to(word_tags_path)
        follow_redirect!
        expect(response.body).to include("他のユーザーのタグは変更できません。")
      end
    end
  end
end
