require 'rails_helper'

RSpec.describe UserWord, type: :model do
  describe 'associations' do
    it {should belong_to(:user)}
    it {should belong_to(:word)}
  end

  describe 'validations' do
    let(:user) {User.create(name: "Test", email: "test@example.com",password: "password123", password_confirmation:"password123")}
    let(:word) {Word.create(japanese: "犬", english: "dog")}

    it "does not allow duplicate user-word combinations" do
      UserWord.create(user: user, word: word)
      duplicate = UserWord.new(user: user, word: word)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:word_id]).to include("has already been taken")
    end
    
    it "does not allow correct_count to exceed quiz_count" do
    user_word = UserWord.new(user: user, word: word, quiz_count: 5, correct_count: 6)

    expect(user_word).not_to be_valid
    expect(user_word.errors[:correct_count]).to include("cannot exceed quiz count")

    end

  end


  describe '#accuracy' do
   let(:user) {User.create(name: "Test", email: "test@example.com", password: "password123", password_confirmation:"password123")}
   let(:word) {Word.create(japanese: "猫", english: "cat")  }

   it "returns 0 when quiz_count is 0" do
     user_word = UserWord.new(user: user, word: word, quiz_count: 0, correct_count: 0)
     expect(user_word.accuracy).to eq(0)
   end

   it "calculates accuracy correctly" do
     user_word = UserWord.new(user: user, word: word, quiz_count: 10, correct_count: 7)
     expect(user_word.accuracy).to eq(70.0)
   end
  end
  



end