class WordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_word, only: [ :show, :edit, :update, :destroy ]

  def index
    @words = Word.all

    if params[:search].present?
       search_params = params[:search]

      if search_params[:japanese].present?
        @words = @words.where("japanese LIKE ?", "%#{search_params[:japanese]}%")

      end

      if search_params[:english].present?
        @words = @words.where("english LIKE ?", "%#{search_params[:english]}%")
      end

      if search_params[:word_tag_id].present?
        @words = @words.joins(:word_taggings).where(word_taggings: { word_tag_id: search_params[:word_tag_id] })
      end
    end
    @words = @words.distinct.order(:japanese)
    @word_tags = WordTag.system_tags.order(:name)
  end
  def show
  end
  def new
    @word= Word.new
    @word_tags = WordTag.for_user(current_user).order(:name)
    3.times { @word.synonyms.build }
  end

  def create
    @word = Word.new(word_params)

    if @word.save
      flash[:notice] = "単語を登録しました。"
      redirect_to words_path
    else
      @word_tags = WordTag.for_user(current_user).order(:name)
      flash.now[:alert] = "登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @word_tags = WordTag.for_user(current_user).order(:name)

    if @word.synonyms.empty?
      3.times { @word.synonyms.build }
    end
  end

  def update
    if @word.update(word_params)
      flash[:notice]= "単語を更新しました。"
      redirect_to words_path
    else
      @word_tags = WordTag.system_tags.order(:name)
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

    def destroy
      @word.destroy
      flash[:notice] = "単語を削除しました。"
      redirect_to words_path
    end



  private
  def set_word
    @word = Word.find(params[:id])
  end

  def word_params
    params.require(:word).permit(:japanese, :english, :reading, :image, word_tag_ids: [], synonyms_attributes: [ :id, :synonym_word, :_destroy ])
  end
end
