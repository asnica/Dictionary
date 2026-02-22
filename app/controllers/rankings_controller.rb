class RankingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @rankings = User
      .joins(:quiz_sessions)
      .where(quiz_sessions: { status: "completed" })
      .group("users.id")
      .select(
        "users.id",
        "users.email",
        "AVG(quiz_sessions.score) as avg_score",
        "COUNT(quiz_sessions.id) as total_quizzes",
        "AVG(quiz_sessions.score * 100.0 / #{QuizSession::QUESTION_COUNT}) as avg_accuracy"
      )
      .order(Arel.sql("AVG(quiz_sessions.score * 100.0 / #{QuizSession::QUESTION_COUNT}) DESC, COUNT(quiz_sessions.id) DESC"))
      .page(params[:page]).per(20)

    @user_quiz_count = current_user.quiz_sessions.where(status: "completed").count
    @user_avg_score  = current_user.quiz_sessions.where(status: "completed").average(:score)&.round(2) || 0

    user_ranks = User
      .joins(:quiz_sessions)
      .where(quiz_sessions: { status: "completed" })
      .group("users.id")
      .select("users.id, AVG(quiz_sessions.score * 100.0 / #{QuizSession::QUESTION_COUNT}) as avg_accuracy")
      .order(Arel.sql("AVG(quiz_sessions.score * 100.0 / #{QuizSession::QUESTION_COUNT}) DESC"))
      .pluck(:id)

    @user_rank = user_ranks.index(current_user.id)&.+(1) || "Unranked"
  end
end
