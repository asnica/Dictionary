class RankingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @session = nil
    if params[:session_id].present?
      @session = current_user.quiz_sessions.find_by(id: params[:session_id], status: "completed")
    end

    @rankings = User
      .joins(:quiz_sessions)
      .where(quiz_sessions: { status: "completed" })
      .group("users.id")
      .select(
        "users.id",
        "users.name",
        "MAX(quiz_sessions.score) as best_score",
        "MAX(quiz_sessions.score * 100.0 / #{QuizSession::QUESTION_COUNT}) as best_accuracy",
        "RANK() OVER (ORDER BY MAX(quiz_sessions.score * 100.0 / #{QuizSession::QUESTION_COUNT}) DESC) as rank"
      )
      .order(Arel.sql("rank ASC"))
      .page(params[:page]).per(20)

    completed = current_user.quiz_sessions.where(status: "completed")
    @user_quiz_count = completed.count

    user_highest = completed.order(score: :desc).first
    @user_highest_score = user_highest ? (user_highest.score * 100.0 / QuizSession::QUESTION_COUNT) : 0

    user_ranks = User
      .joins(:quiz_sessions)
      .where(quiz_sessions: { status: "completed" })
      .group("users.id")
      .order(Arel.sql("MAX(quiz_sessions.score * 100.0 / #{QuizSession::QUESTION_COUNT}) DESC"))
      .pluck("users.id")

    @user_rank = user_ranks.index(current_user.id)&.+(1) || "Unranked"
  end
end
