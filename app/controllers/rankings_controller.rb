class RankingsController < ApplicationController
  before_action :authenticate_user!

def show
  @rankings = User
    .joins(:quizzes)
    .where(quizzes: { status: "completed" })
    .group("users.id")
    .select(
      "users.id",
      "users.name",
      "AVG(quizzes.score) as avg_score",
      "Count(quizzes.id) as total_quizzes",
      "AVG(quizzes.score * 100.0 / quizzes.total_questions) as avg_accuracy"
    )
      .order(Arel.sql("AVG(quizzes.score * 100.0 / quizzes.total_questions) DESC, Count(quizzes.id) DESC"))
      .page(params[:page]).per(20)

    @user_quiz_count = current_user.quizzes.where(status: "completed").count
    @user_avg_score = current_user.quizzes.where(status: "completed").average(:score)&.round(2) || 0

    user_ranks = User
      .joins(:quizzes)
      .where(quizzes: { status: "completed" })
      .group("users.id")
      .select("users.id, AVG(quizzes.score * 100.0 / quizzes.total_questions) as avg_accuracy")
      .order(Arel.sql("AVG(quizzes.score * 100.0 / quizzes.total_questions) DESC"))
      .pluck(:id)

    @user_rank = user_ranks.index(current_user.id)&.+(1) || "Unranked"
end
end
