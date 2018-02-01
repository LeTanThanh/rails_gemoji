module CustomEmojiHelper
  attr_accessor :emoji_char_codepoints

  def is_emoji_char? char
    @emoji_char_codepoints ||= (0x1F600...0x1F64F).to_a +
      (0x1F300...0x1F5FF).to_a +
      (0x1F680...0x1F6FF).to_a +
      (0x2600...0x26FF).to_a +
      (0x2700...0x27BF).to_a +
      (0xFE00...0xFE0F).to_a +
      (0x1F900...0x1F9FF).to_a +
      (0x1F1E6...0x1F1FF).to_a

    @emoji_char_codepoints.include? char.codepoints.first
  end

  def emoji_image_url char
    providers = ["apple", "emoji-one", "emojidex", "emojipedia", "facebook", "google", "htc", "lg", "messenger", "microsoft", "mozilla", "samsung", "twitter"]
    base_url = "https://raw.githubusercontent.com/loicpirez/EmojiExtractor/master/emojipedia.org"
    image_name = char.codepoints.map { |c| c.to_s(16).rjust(4, '0') }.join('-').gsub(/-(fe0f|200d)\b/, '')

    providers.each do |provider|
      image_url = "#{base_url}/#{provider}/#{image_name}.png"
      return image_url if url_exists?(image_url)
    end
  end

  def url_exists? url
    begin
      uri = URI.parse url
      request = Net::HTTP.new uri.host, uri.port
      request.use_ssl = true
      result = request.request_head uri.path
      result.code == "200"
    rescue
      false
    end
  end

  def insert_emoji_image content
    emoji_chars = []

    content.each_char do |char|
      if is_emoji_char?(char)
        emoji_chars << char
      end
    end

    emoji_chars.each do |emoji_char|
      content.gsub! emoji_char, "<img src=#{emoji_image_url emoji_char} style='vertical-align:middle; width: 18px; height: 18px;' >"
    end

    content.html_safe
  end
end
