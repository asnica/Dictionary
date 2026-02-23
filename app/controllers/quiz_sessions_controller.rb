class QuizSessionsController < ApplicationController
  before_action :authenticate_user!

  def index
  @in_progress = QuizSession.in_progress(current_user)
  @completed = QuizSession.completed(current_user)
  end

  def play
    @session = current_user.quiz_sessions.find_by(id: params[:id], status: "in_progress")
    redirect_to quiz_sessions_path, alert: "進行中のセッションが見つかりません" unless @session
  end

  def create
   session = QuizSession.start_new!(current_user)
   redirect_to play_quiz_session_path(session)
  end

  def show
   @session = current_user.quiz_sessions.find_by(id: params[:id], status: "completed")
   redirect_to quiz_sessions_path, alert: "完了したセッションが見つかりません" unless @session
  end

 def retry
   prev_session = current_user.quiz_sessions.find_by(id: params[:id])
   redirect_to quiz_sessions_path and return unless prev_session

   session = QuizSession.retry_from!(current_user, prev_session)
   redirect_to play_quiz_session_path(session)
 end

 def current_question
   session = current_user.quiz_sessions.find_by(id: params[:id], status: "in_progress")
   return render json: { error: "進行中のセッションが見つかりません" }, status: :not_found unless session
   return render json: { finished: true, session_id: session.id } if session.finished?

   word = session.current_word
   existing = session.user_answers.find_by(word: word)


   render json: {

     word_index: session.current_index + 1,
     total: session.word_order.size,
     japanese: word.japanese,
     reading: word.reading,

     choices: session.current_choices,
     saved_answer: existing&.selected_answer
   }
 end

 def previous
   session = current_user.quiz_sessions.find_by(id: params[:id], status: "in_progress")
   return render json: { error: "進行中のセッションが見つかりません" }, status: :not_found unless session

   session.previous!
   render json: { current_index: session.current_index }
 end

 def destroy
    session = current_user.quiz_sessions.find_by(id: params[:id])
    return redirect_to quiz_sessions_path, alert: "セッションが見つかりません" unless session

    session.destroy
    redirect_to quiz_sessions_path, notice: "セッションが削除されました。"
 end
end
