require 'rails_helper'

RSpec.describe Word, type: :model do
  describe "associations" do
    it { should have_many(:user_words).dependent(:destroy) }
    it { should have_many(:users).through(:user_words) }
    it { should have_many(:word_taggings).dependent(:destroy) }
    it { should have_many(:word_tags).through(:word_taggings) }
    it { should have_many(:synonyms).dependent(:destroy) }
  end


  describe 'validations' do
    describe 'japanese uniqueness' do
    it "does not allow duplicate japanese words" do
      Word.create!(japanese: "猫", english: "cat")
      word = build(:word, japanese: "猫", english: "dog")
      expect(word).not_to be_valid
    end
  end

  describe 'english presence' do
    it "validates presence of english" do
      word = build(:word, english: nil)
      expect(word).not_to be_valid
    end
  end
  end


  describe 'uniqueness' do
    it "does not allow duplicate japanese words" do
      Word.create!(japanese: "猫", english: "cat")
      duplicate_word = Word.new(japanese: "猫", english: "feline")

      expect(duplicate_word).not_to be_valid
      expect(duplicate_word.errors[:japanese]).to include("has already been taken")
    end
  end

  describe "tagging functionality" do
    let(:user) { User.create(name: "Test", email: "test@example.com", password: "password123", "password_confirmation": "password123") }
    let(:word) { Word.create(japanese: "犬", english: "dog") }
    let(:tag1) { WordTag.create(name: "N5", user_id: nil, category: "system") }
    let(:tag2) { WordTag.create(name: "名詞", user_id: nil, category: "system") }
    it "can have multiple tags" do
      word.word_tags << tag1
      word.word_tags << tag2

      expect(word.word_tags.count).to eq(2)
      expect(word.word_tags).to include(tag1, tag2)
    end
    it "does not allow duplicate tags" do
      word.word_tags << tag1
      expect {
        word.word_tags << tag1
    }.to raise_error(ActiveRecord::RecordNotUnique)
    end
    it "#tag_names returns array of tag names" do
      word.word_tags << tag1
      word.word_tags << tag2
      expect(word.tag_names).to match_array([ "N5", "名詞" ])
    end
    it "#has_tag? checks for tag existence" do
      word.word_tags << tag1

      expect(word.has_tag?("N5")).to be true
      expect(word.has_tag?("名詞")).to be false
    end
  end

  describe "synonyms functionality" do
    let(:word) { Word.create(japanese: "速い", english: "fast") }
    it "can have multiple synonyms" do
      word.synonyms.create(synonym_word: "迅速な")
      word.synonyms.create(synonym_word: "素早い")

      expect(word.synonyms.count).to eq(2)
      expect(word.synonyms.pluck(:synonym_word)).to include("迅速な", "素早い")
    end
    it "does not allow duplicate synonyms for the same word" do
      word.synonyms.create(synonym_word: "迅速な")
      duplicate = word.synonyms.build(synonym_word: "迅速な")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:synonym_word]).to include("has already been taken")
    end

    it "deletes synonyms when word is deleted" do
      word.synonyms.create(synonym_word: "迅速な")
      word.synonyms.create(synonym_word: "素早い")

      expect {
        word.destroy
      }.to change { Synonym.count }.by(-2)
    end
  end

  describe "nested attributes for synonyms" do
    it "accepts nested attributes for synonyms" do
      word = Word.new(
        japanese: "犬",
        english: "dog",
        synonyms_attributes: [
          { synonym_word: "いぬ" },
          { synonym_word: "ワンちゃん" }
        ]
      )
      expect(word.save).to be true
      expect(word.synonyms.count).to eq(2)
    end
  end

  describe "image attagement" do
    it "can have an image attached" do
      word = Word.create(japanese: "花", english: "flower")

      image_file = fixture_file_upload(
        Rails.root.join('spec', 'fixtures', 'files', 'test.jpg'),
        'image/jpeg'
      )
      word.image.attach(image_file)
      expect(word.image).to be_attached
    end
  end
end
