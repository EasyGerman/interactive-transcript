class TranslateController < ApplicationController
  def translate
    respond_to do |format|
      format.json do
        translated_text =
          TranslationCache.with_key_cache(params[:key], "en") do |original, lang|
            resp = Faraday.get("https://api.deepl.com/v2/translate",
              auth_key: ENV.fetch('DEEPL_API_KEY'),
              source_lang: 'de',
              target_lang: lang,
              text: original
            )
            data = JSON.parse(resp.body)
            data.fetch('translations').first.fetch('text')
          end

        render json: { text: translated_text }
      end
    end
  end
end
