module CensorshipHelper
  def cut_adult_words(sentence = nil)
    sentence.to_s.gsub(/(xxx|\bporn\b|\bsex\b|\btits\b|\bboobs\b|\bass\b|\bpussy\b|\bcum\b|\b69\b)/i, '').squish
  end
end
