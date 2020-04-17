class TranslateController < ApplicationController
  skip_before_action :verify_authenticity_token

  def translate
    respond_to do |format|
      format.json do
        translated_text = Translator.translate_from_key(params[:key])

        render json: { text: translated_text }
      end
    end
  end
end
