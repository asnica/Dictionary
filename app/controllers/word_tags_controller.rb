class WordTagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_word_tag, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user!, only: [ :edit, :update, :destroy ]

  def index
    @system_tags = WordTag.system_tags.order(:name)

    if params[:search].present?
       @custom_tags = current_user.word_tags
                          .where("name ILIKE ?", "%#{params[:search]}%")
                          .order(created_at: :desc)
    else
      @custom_tags = current_user.word_tags.order(created_at: :desc)
    end
  end

  def show
    @words = @word_tag.words.order(:japanese)
  end




  def new
    @word_tag = WordTag.new
  end

  def create
    @word_tag = current_user.word_tags.build(word_tag_params)
    @word_tag.category = "custom"

    if @word_tag.save
      flash[:notice] = "タグが作成されました。"
      redirect_to word_tags_path
    else
      flash.now[:alert] = "登録に失敗しました。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @word_tag.update(word_tag_params)
      flash[:notice] = "タグが更新されました。"
      redirect_to word_tags_path
    else
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @word_tag.destroy
    flash[:notice] = "タグが削除されました。"
    redirect_to word_tags_path
  end


  private

  def set_word_tag
    @word_tag = WordTag.find(params[:id])
  end

  def authorize_user!
    if @word_tag.system_tag?
      flash[:alert] = "システムタグは変更できません。"
      redirect_to word_tags_path
      return
    end

    unless @word_tag.user ==current_user
      flash[:alert] = "他のユーザーのタグは変更できません。"
      redirect_to word_tags_path
    end
  end

  def word_tag_params
    params.require(:word_tag).permit(:name, :description, :color)
  end
end
