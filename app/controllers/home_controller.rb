class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @recommended_words = JishoService.fetch_random_word("n3")

    if @recommended_words.nil?
      @recommended_words = { word: "勉強", reading: "べんきょう", meaning: "study" } # デフォルトの単語
    end
  end
end
