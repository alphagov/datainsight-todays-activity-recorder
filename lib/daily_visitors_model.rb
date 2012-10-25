require_relative "date_extension"

class DailyVisitorsModel
  def visitors_for(date)
    date = date.to_datetime
    daily_unique_visitors = DailyUniqueVisitors.first(:start_at => date.to_midnight)

    daily_unique_visitors ? daily_unique_visitors.value : nil
  end
end