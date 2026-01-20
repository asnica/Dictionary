class WordTagsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_word_tag, only: [:edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    @system_tags = WordTag.system_tags.order(:name)
    @custom_tags = current_user.word_tags.order(created_at: :desc)
  end

  def new
    @word_tag = WordTag.new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
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
    params.require(:word_tag).permit(:name, :description, :color )
  end



end
