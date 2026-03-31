class RankingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @session = nil
    if params[:session_id].present?
      @session = current_user.quiz_sessions.find_by(id: params[:session_id], status: "completed")
    end

    @rankings = User.with_quiz_stats.order(Arel.sql("rank ASC")).page(params[:page]).per(20)

    completed = current_user.quiz_sessions.where(status: "completed")
    @user_quiz_count = completed.count

    user_highest = completed.order(score: :desc).first
    @user_highest_score = user_highest ? (user_highest.score * 100.0 / QuizSession::QUESTION_COUNT) : 0

    

    @user_rank = User.from("(#{User.with_quiz_stats.to_sql}) as ranked_users").where(ranked_users:{id:current_user.id}).pick(:rank) || "Unranked"


  end
end
