class WordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_word, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_word_edit, only: [ :edit, :update, :destroy ]
  skip_before_action :verify_authenticity_token, only: [:generate_image]

  def index
    @word_tags = WordTag.all
    @words = filter_words.distinct.order(:japanese).page(params[:page]).per(10)
  end
  def show
  end



  def new
    @word ||= Word.new
    @word_tags = WordTag.for_user(current_user).order(:name)
    3.times { @word.synonyms.build } if @word.new_record? && @word.synonyms.empty?
  end

  def create
    @word = Word.new(word_params_create)

    if @word.save
      UserWord.create(user_id: current_user.id, word_id: @word.id)
      flash[:notice] = "単語を登録しました。"
      redirect_to words_path
    else
      @word_tags = WordTag.for_user(current_user).order(:name)
      3.times { @word.synonyms.build } if @word.synonyms.count < 3
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
    if @word.update(word_params_update)
      flash[:notice]= "単語を更新しました。"
      redirect_to words_path
    else
      @word_tags = WordTag.for_user(current_user).order(:name)
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end





    def destroy
      @word.destroy
      flash[:notice] = "単語を削除しました。"
      redirect_to words_path
    end

def export_csv
     @words = filter_words.distinct.order(:japanese)


     require "csv"
     utf8_csv = CSV.generate(headers: true, row_sep: "\r\n") do |csv|
       csv << [ "日本語", "読み", "意味" ]
       @words.each do |word|
         csv << [ word.japanese, word.reading, word.english ]
       end
     end


     csv_data = utf8_csv.encode(
       Encoding::CP932,
       invalid: :replace,
       undef: :replace,
       replace: "?"
     )


     send_data csv_data,
       filename: "words_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
       type: "text/csv; charset=shift_jis",
       disposition: "attachment"
   end



   # def export_csv
   #   @words = filter_words.distinct.order(:japanese)

   #   require "csv"
   #   csv_data = CSV.generate(headers: true) do |csv|
   #     csv << [ "日本語", "読み", "意味" ]
   #     @words.each do |word|
   #       csv << [ word.japanese, word.reading, word.english ]
   #     end
   #   end

   #   send_data csv_data,
   #     filename: "words_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv",
   #     type: "text/csv; charset=shift_jis",
   #     disposition: "attachment"
   # end

     def generate_image
      result = ImageGenerationService.new(
        user: current_user,
        prompt: params[:prompt]).call

      if result.success?
        render json: {
          success: true,
          image_url: result.image_url,
          credits_remaining: current_user.reload.image_credits
        }
      else
        p "API Error: #{result.error}"
        render json: {
          success: false,
          error: result.error
        }, status: :unprocessable_entity
      end
    end




  private

 def filter_words
  my_word     = UserWord.where(user_id: current_user.id).select(:word_id)

  words = Word.where(
    Word.arel_table[:active].eq(true)
        .or(Word.arel_table[:id].in(my_word.arel))
  )

  if params[:search].present?
    search_params = params[:search]

    words = words.where("japanese LIKE ?", "%#{search_params[:japanese]}%") if search_params[:japanese].present?
    words = words.where("english LIKE ?", "%#{search_params[:english]}%") if search_params[:english].present?

    if search_params[:word_tag_name].present?
      words = words.joins(word_taggings: :word_tag)
                   .where(word_tags:{ name: search_params[:word_tag_name]})
    end

    if search_params[:synonym].present?
      words = words.joins(:synonyms)
                   .where("synonyms.synonym_word LIKE ?", "%#{search_params[:synonym]}%")
    end

    if search_params[:created_by_me] == "1"
      words = words.where(id: my_word)
    end
  end

  words.includes(user_words: :user, word_tags: [], synonyms: [], image_attachment: :blob)
end





    def set_word
      @word = Word.find(params[:id])
    end

    def word_params_create
      params.require(:word).permit(
        :japanese,
        :reading,
        :english,
        :image,
        :remove_image,
                :ai_image_url,

        word_tag_ids: [],
      synonyms_attributes: [ :id, :synonym_word, :_destroy ],

      )
    end

    def word_params_update
      params.require(:word).permit(

        :image,
        :remove_image,
        :active,
                :ai_image_url,

        word_tag_ids: [],
      synonyms_attributes: [ :id, :synonym_word, :_destroy ],
      )
    end

    def authorize_word_edit
      unless UserWord.exists?(user_id: current_user.id, word_id: params[:id])
      flash[:alert] = "この単語を編集する権限がありません。"
      redirect_to words_path
      end
    end
end
