require 'rails_helper'

RSpec.describe "Words", type: :request do
  let(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password", password_confirmation: "password") }
  let!(:tag_n5) { WordTag.create(name: "N5", category: "system", color: "#FF0000", user_id: nil) }
  let!(:tag_noun) { WordTag.create(name: "名詞", category: "system", color: "#2196F3", user_id: nil) }

  let!(:word1) { Word.create!(japanese: "猫", english: "cat", reading: "ねこ") }
  let!(:word2) { Word.create!(japanese: "犬", english: "dog", reading: "いぬ") }
  let!(:word3) { Word.create!(japanese: "鳥", english: "bird", reading: "とり") }

  before do
    word1.word_tags << tag_n5
    word1.word_tags << tag_noun

    word2.word_tags << tag_n5

    post login_path, params: {
      session: {
        email: user.email,
        password: "password"
      }
    }
    follow_redirect!
  end

  describe "GET /words" do
    it "returns a success" do
      get words_path
      expect(response).to have_http_status(200)
    end

    it "assigns all words to @words" do
      get words_path
      expect(assigns(:words)).to match_array([ word1, word2, word3 ])
    end
    context "with japanese search" do
      it "filters by japnanese" do
        get words_path, params: { search: { japanese: "猫" } }
        expect(assigns(:words)).to include(word1)
        expect(assigns(:words)).not_to include(word2, word3)
      end
    end
    context "with english search" do
      it "filters by english" do
        get words_path, params: { search: { english: "dog" } }
        expect(assigns(:words)).to include(word2)
        expect(assigns(:words)).not_to include(word1, word3)
      end
    end
    context "with tag search" do
      it "filters by word_tag_id" do
        get words_path, params: { search: { word_tag_id: tag_noun.id } }
        expect(assigns(:words)).to include(word1)
        expect(assigns(:words)).not_to include(word2, word3)
      end
    end
    context "with combined search" do
      it "filters by multiple criteria" do
        get words_path, params: {
          search: {
            japanese: "犬", word_tag_id: tag_n5.id
          }
        }
        expect(assigns(:words)).to include(word2)
        expect(assigns(:words)).not_to include(word1, word3)
      end
    end
  end
end
