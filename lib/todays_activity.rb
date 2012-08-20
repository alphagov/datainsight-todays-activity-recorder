require_relative "date_extension"

class TodaysActivity


  def todays_activity
    live_at = self.live_at


    visitors_today = visitors_today_by_hour(live_at)
    visitors_yesterday = visitors_yesterday_by_hour(live_at)
    last_month_average = last_month_average_by_hour(live_at)

    values = 24.times.map do |hour|
      result = {:hour_of_day => hour, :visitors => {}}
      result[:visitors][:today] = visitors_today[hour] if hour < visitors_today.length
      result[:visitors][:yesterday] = visitors_yesterday[hour]
      result[:visitors][:monthly_average] =last_month_average[hour]

      result
    end

    {
      :values => values,
      :live_at => live_at
    }
  end

  def live_at
    UniqueVisitors.max(:collected_at)
  end

  def visitors_today_by_hour(live_at)
    result = UniqueVisitors.all(
      :start_at.gte => live_at.to_midnight,
      :end_at.lte => live_at
    )
    visitors = []
    result.each {|measurement| visitors[measurement.start_at.hour] = measurement.value }
    visitors
  end

  def visitors_yesterday_by_hour(live_at)
    result = UniqueVisitors.all(
      :start_at.gte => live_at.to_midnight - 1,
      :start_at.lt => live_at.to_midnight
    )
    visitors = [nil] * 24
    result.each {|measurement| visitors[measurement.start_at.hour] = measurement.value }
    visitors
  end

  def last_month_average_by_hour(live_at)
    result = UniqueVisitors.all(
      :start_at.gte => (live_at.to_midnight - 30),
      :end_at.lt => live_at.to_midnight
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
