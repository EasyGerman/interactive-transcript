class TranslateController < ApplicationController
  def translate
    respond_to do |format|
      format.json do
        translated_text = Translator.translate_from_key(params[:key])

        render json: { text: translated_text }
      end
    end
  end
end
