module CensorshipHelper
  def cut_adult_words(sentence = nil)
    sentence.to_s.gsub(/xxx/i, '').strip
  end
end
