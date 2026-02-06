
class QuizzesController < ApplicationController
 before_action :authenticate_user!
 before_action :set_quiz, only: [ :show, :submit_answer, :next_question, :previous_question, :grade, :result, :restart, :pause ]

 def index
   @current_quiz = current_user.current_quiz
   @completed_quizzes = current_user.completed_quizzes.limit(5)
   @words_count = Word.count
 end

 def create
   if Word.count<10
     redirect_to quizzes_path, alert: "クイズを始めるには、少なくとも10個の単語が必要です。"
     return

   end
   @quiz = current_user.quizzes.create!(
     total_questions: 10,
     status: "not_started",
     current_questions_number: 0
   )
   @quiz.generate_questions!
   redirect_to quiz_path(@quiz), notice: "新しいクイズを開始しました！"
 end

 def pause
   @current_question = @quiz.current_question
   @question_number = @quiz.current_questions_number + 1
   @quiz.update!(status: "in_progress", recently_worked: Time.current)
   redirect_to quizzes_path, notice: "クイズを中断しました。続きから再開できます。"
 end

 def show
   @current_question = @quiz.current_question
   @question_number = @quiz.current_questions_number + 1
 end

 def submit_answer
   @current_question = @quiz.current_question
   answer = params[:answer]

   @current_question.submit_answer!(answer)

   respond_to do |format|
     format.json {
      render json: {
        success: true,
        is_correct: @current_question.is_correct,
        correct_answer: @current_question.correct_answer
      }
     }
   end
 end

 def next_question
   @quiz.move_to_next_question!
   @current_question = @quiz.current_question
   @question_number = @quiz.current_questions_number + 1
   respond_to do |format|
     format.js
   end
 end

 def previous_question
   @quiz.move_to_previous_question!
   @current_question = @quiz.current_question
   @question_number = @quiz.current_questions_number + 1
   respond_to do |format|
     format.js
   end
 end

 def grade
   @quiz.grade!
   redirect_to result_quiz_path(@quiz), notice: "クイズが完了しました！結果を確認してください。"
 end

 def result
   @quiz_questions = @quiz.quiz_questions.includes(:word).order(:id)
 end


 def restart
   new_quiz = current_user.quizzes.create!(
    total_questions: @quiz.total_questions,
    status: "not_started",
    current_questions_number: 0
   )

   @quiz.quiz_questions.each do |old_question|
     new_quiz.quiz_questions.create!(
      word: old_question.word,
      choices: old_question.choices)
   end
   new_quiz.update!(status: "in_progress", started_at: Time.current)
   redirect_to quiz_path(new_quiz), notice: "クイズを再開しました！"
 end






 def past_quizzes
   @completed_quizzes = current_user.completed_quizzes.page(params[:page]).per(10)
 end

 private
  def set_quiz
    @quiz = current_user.quizzes.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    redirect_to quizzes_path, alert: "クイズが見つかりません。"
  end
end
