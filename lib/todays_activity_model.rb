require_relative "date_extension"

class TodaysActivityModel


  def todays_activity
    last_collected_at = self.last_collected_at


    visitors_yesterday = visitors_yesterday_by_hour(last_collected_at)
    last_week_average = last_week_average_by_hour(last_collected_at)

    data = 24.times.map do |hour|
      result = {:hour_of_day => hour, :value => {}}
      result[:value][:yesterday] = visitors_yesterday[hour]
      result[:value][:last_week_average] =last_week_average[hour]

      result
    end

    {
      :source => ["Google Analytics"],
      :metric => 'visitors',
      :for_date => (last_collected_at - 1).to_date,
      :data => data
    }
  end

  def last_collected_at
    HourlyUniqueVisitors.max(:collected_at) || DateTime.parse("1970-01-01T00:00:00+00:00")
  end

  def visitors_yesterday_by_hour(last_collected_at)
    result = HourlyUniqueVisitors.all(
      :start_at.gte => last_collected_at.to_midnight - 1,
      :start_at.lt => last_collected_at.to_midnight
    )
    visitors = [nil] * 24
    result.each {|measurement| visitors[measurement.start_at.hour] = measurement.value }
    visitors
  end

  def last_week_average_by_hour(last_collected_at)
    result = HourlyUniqueVisitors.all(
      :start_at.gte => (last_collected_at - last_collected_at.wday).to_midnight - 7,
      :end_at.lte => (last_collected_at - last_collected_at.wday).to_midnight
    ).group_by { |each| each.start_at.hour }.map { |hour, visitors| [hour, average(visitors)] }
    visitors = [nil] * 24
    result.each {|hour, avg| visitors[hour] = avg}

    visitors
  end

  def average unique_visitors
    if unique_visitors.empty?
      0.0
    else
      values = unique_visitors.map(&:value)
      values.reduce(&:+).to_f / values.length
    end
  end
end
