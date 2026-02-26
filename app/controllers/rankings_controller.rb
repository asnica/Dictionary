class RankingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @rankings = User
      .joins(:quiz_sessions)
      .where(quiz_sessions: { status: "completed" })
      .group("users.id")
      .select(
        "users.id",
        "users.name",
        "AVG(quiz_sessions.score) as avg_score",
        "COUNT(quiz_sessions.id) as total_quizzes",
        "AVG(quiz_sessions.score * 100.0 / #{QuizSession::QUESTION_COUNT}) as avg_accuracy",
        "RANK() OVER (ORDER BY AVG(quiz_sessions.score * 100.0 / #{QuizSession::QUESTION_COUNT}) DESC, COUNT(quiz_sessions.id) DESC) as rank"
      )
      .order(Arel.sql("rank ASC"))
      .page(params[:page]).per(20)



    completed = current_user.quiz_sessions.where(status: "completed")
    @user_quiz_count = completed.count
    @user_avg_score = (completed.average(:score).to_f * 100.0 / QuizSession::QUESTION_COUNT) || 0



    user_ranks = User
      .joins(:quiz_sessions)
      .where(quiz_sessions: { status: "completed" })
      .group("users.id")
      .order(Arel.sql("AVG(quiz_sessions.score * 100.0 / #{QuizSession::QUESTION_COUNT}) DESC"))
      .pluck("users.id")

    @user_rank = user_ranks.index(current_user.id)&.+(1) || "Unranked"
  end
end
