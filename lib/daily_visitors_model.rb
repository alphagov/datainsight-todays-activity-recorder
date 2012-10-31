require_relative "date_extension"

class DailyVisitorsModel
  def visitors_for(date)
    daily_unique_visitors = DailyUniqueVisitors.first(:start_at => to_midnight(date))

    daily_unique_visitors ? daily_unique_visitors.value : nil
  end

  def updated_at(*dates)
    DailyUniqueVisitors.max(:updated_at, :start_at => dates.map {|date| to_midnight(date) })
  end

  private
  def to_midnight(date)
    date.to_datetime.to_midnight
  end
end