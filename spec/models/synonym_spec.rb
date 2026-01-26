require 'rails_helper'

RSpec.describe Synonym, type: :model do
  describe "associations" do
    it { should belong_to(:word) }
  end

  describe "validations" do
    let(:word) { Word.create(japanese: "猫", english: "cat") }
    it { should validate_presence_of(:synonym_word) }
    it { should validate_length_of(:synonym_word).is_at_most(100) }

    it "validates uniqueness of synonym_word scoped to word_id" do
      word.synonyms.create(synonym_word: "ネコ")
      duplicate = word.synonyms.build(synonym_word: "ネコ")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:synonym_word]).to include("has already been taken")
    end
    it "allows same synonym_word for different words" do
      word1 = Word.create(japanese: "犬", english: "dog")
      word2  = Word.create(japanese: "猫", english: "cat")

      word1.synonyms.create(synonym_word: "ペット")
      synonym = word2.synonyms.build(synonym_word: "ペット")
      expect(synonym).to be_valid
    end
  end
end
