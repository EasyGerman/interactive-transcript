class TranslateController < ApplicationController
  skip_before_action :verify_authenticity_token

  def translate
    respond_to do |format|
      format.json do
        Rails.logger.info("Translate: key=#{params[:key]} lang=#{params[:lang]} ip=#{request.ip} ua=#{request.user_agent.inspect}")
        translated_text = Translator.translate_from_key(params[:key], params[:lang])

        render json: { text: translated_text }
      end
    end
  end

  rescue_from Translator::Error do |error|
    Rollbar.error(error)
    render json: { error: { message: "Translation failed" } }, status: 500
  end
end
