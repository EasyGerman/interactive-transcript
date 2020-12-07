class FeedbackController < ApplicationController
  def feedback
    respond_to do |format|
      format.json do
        Feedback.create!(outcome: params[:outcome])
        render json: { ok: true }
      end
    end
  end
end
