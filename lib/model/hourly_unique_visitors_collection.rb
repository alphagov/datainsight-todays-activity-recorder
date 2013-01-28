require_relative "day"

class HourlyUniqueVisitorsCollection

  attr_reader :results

  def initialize(hourly_unique_visitors)
    @results = hourly_unique_visitors.dup
  end

  def self.six_week_period_until(upto)
    date_limit = upto.to_midnight
    HourlyUniqueVisitorsCollection.new(HourlyUniqueVisitors.period(date_limit - 7*6, date_limit))
  end

  def filter_by_day(day)
    HourlyUniqueVisitorsCollection.new(@results.select { |visitor| visitor.start_at.wday == day })
  end

  def hourly_average
    averages = [nil] * 24
    @results
      .group_by { |huv| huv.start_at.hour }
      .each { |h, huv_list| averages[h] = mean( huv_list.map(&:value) ) }
    averages
  end

  private
  def mean(values)
    values.inject(0.0, &:+) / values.count
  end

end
