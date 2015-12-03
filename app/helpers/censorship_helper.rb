module CensorshipHelper
  def cut_adult_words(sentence = nil)
    sentence.to_s.gsub(APP_CONFIG['adult_filter_regex'], '').squish
  end
end
