class TranslateController < ApplicationController
  def translate
    respond_to do |format|
      format.json do
        clean_text = params[:text].gsub(%r{^.*\[((\d{1,2}:)?\d{1,2}:\d{2})\]\s+(.*)$}, "\\3")

        translated_text =
          Rails.cache.fetch("translation/#{Digest::MD5.hexdigest(clean_text)}", expires_in: 1.year) do
            resp = Faraday.get("https://api.deepl.com/v2/translate",
              auth_key: ENV.fetch('DEEPL_API_KEY'),
              source_lang: 'de',
              target_lang: 'en',
              text: clean_text
            )
            data = JSON.parse(resp.body)
            data.fetch('translations').first.fetch('text')
          end

        render json: { text: translated_text }
      end
    end
  end
end
