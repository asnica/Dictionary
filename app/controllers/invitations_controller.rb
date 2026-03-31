class InvitationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @invitations = current_user.invitations.order(created_at: :desc)
    @invitation = Invitation.new
  end

  def create
    @invitation = current_user.invitations.build(invitation_params)


    if @invitation.save
      InvitationMailer.invite(@invitation).deliver_later
      redirect_to invitations_path, notice: "#{@invitation.email}に招待リンクを送信しました"
    else
      @invitations = current_user.invitations.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end



  private
   def invitation_params
     params.require(:invitation).permit(:email)
   end
end
