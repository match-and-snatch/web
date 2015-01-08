class YearMonth < Struct.new(:year, :month)

  def to_s
    if Time.zone.now.year == year
      Date::MONTHNAMES[month]
    else
      "#{Date::MONTHNAMES[month]} #{year}"
    end
  end

  def ==(other)
    year == other.year && month == other.year
  end
end
