
class TodaysActivity
  def self.visitors_today
    UniqueVisitors.all(
      :start_at.gte => Date.today,
      :end_at.lte => DateTime.now,
      :site => "govuk"
    )
  end

  def self.visitors_yesterday
    UniqueVisitors.all(
      :start_at.gte => Date.today - 1,
      :end_at.lte => Date.today
    )
  end
end