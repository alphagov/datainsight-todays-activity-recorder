class VisitorsNarrative
  def initialize(visitors_one_day_ago, visitors_two_days_ago)
    @metric = VisitorsMetric.new(visitors_one_day_ago, visitors_two_days_ago)
  end

  def message
    if @metric.delta == 0
      "GOV.UK had #{@metric.yesterday} visitors yesterday, about the same as the day before"
    else
      "GOV.UK had #{@metric.yesterday} visitors yesterday, #{@metric.change} of #{@metric.delta}% from the day before"
    end
  end
end

class VisitorsMetric
  def initialize(visitors_one_day_ago, visitors_two_days_ago)
    @yesterday = visitors_one_day_ago
    @the_day_before = visitors_two_days_ago
  end

  def delta
    change_in_visitors = (@the_day_before - @yesterday).abs
    percent_change = (change_in_visitors.to_f / @the_day_before.to_f)*100
    percent_change.round
  end

  def yesterday
    if @yesterday >= 500000
      sprintf("%0.1f million", @yesterday.to_f / 1000000).sub(".0", "")
    else
      sprintf("%i thousand", @yesterday / 1000)
    end
  end

  def change
    if @yesterday > @the_day_before
      "an increase"
    else
      "a decrease"
    end
  end
end