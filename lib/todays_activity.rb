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
        :start_at.lt => Date.today
    )
  end

  def self.last_month_average
    result = UniqueVisitors.all(
        :start_at.gte => (Date.today - 30).strftime,
        :end_at.lt => Date.today.strftime
    ).group_by { |each| each.start_at.hour }
     .map { |hour, visitors| [hour, visitors.map(&:value).reduce(&:+) / visitors.length.to_f] }

    result.map do |hour, value|
      {
          :hour => hour,
          :value => value.round.to_i
      }
    end
  end
end
