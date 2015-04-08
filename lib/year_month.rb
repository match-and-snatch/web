class YearMonth < Struct.new(:year, :month)

  def self.to_date_from_string(year_month_str)
    year_month = Chronic.parse(year_month_str)
    year_month = year_month.change(year: Date.current.year) if year_month.future?
    year_month
  end

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
