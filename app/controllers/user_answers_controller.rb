class UserAnswersController < ApplicationController
  before_action :authenticate_user!

  def create
    session = current_user.quiz_sessions.find_by(id: params[:quiz_session_id], status: "in_progress")
    return render json: { error: "進行中のセッションが見つかりません" }, status: :forbidden unless session

    word = session.current_word
    selected = params[:selected_answer]
    is_correct = selected.present? && selected.strip == word.reading.strip


    answer = session.user_answers.find_or_initialize_by(word: word)
    answer.update!(selected_answer: selected, is_correct: is_correct)


    session.next!
    if session.finished?
      session.complete!
      render json: { finished: true, session_id: session.id }
    else
      render json: { finished: false, current_index: session.current_index }
    end
  end
end
