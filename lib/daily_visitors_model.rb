require_relative "date_extension"

class DailyVisitorsModel
  def visitors_for(date)
    date = date.to_datetime
    UniqueVisitors.sum(:value,
                       :start_at.gte => date.to_midnight,
                       :start_at.lt => date.to_midnight + 1
    )
  end
end