require 'rails_helper'

RSpec.describe Word, type: :model do


  describe 'validations' do
    it {should validate_presence_of(:japanese) }
    it {should validate_presence_of(:english) }
  end


  describe 'uniqueness' do
    it "does not allow duplicate japanese words" do
      Word.create!(japanese: "猫", english: "cat")
      duplicate_word = Word.new(japanese: "猫", english: "feline")

      expect(duplicate_word).not_to be_valid
      expect(duplicate_word.errors[:japanese]).to include("has already been taken")
    end
  end
end
