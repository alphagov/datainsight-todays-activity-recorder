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
    query = "" "
      SELECT HOUR(start_at) as hour, AVG(value) as value
      FROM unique_visitors
      WHERE start_at >= '#{(Date.today-30).strftime}'
      AND end_at < '#{Date.today.strftime}'
      GROUP BY hour
  " ""

    result = DataMapper.repository.adapter.select(query)


    result.map do |struct|
      {
          :hour => struct.hour,
          :value => struct.value.round.to_i
      }
    end
  end
end