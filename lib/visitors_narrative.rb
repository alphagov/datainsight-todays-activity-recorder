class VisitorsNarrative
  def initialize(visitors_one_day_ago, visitors_two_days_ago)
    @visitors_one_day_ago, @visitors_two_days_ago = visitors_one_day_ago, visitors_two_days_ago
    @metric = VisitorsMetric.new(visitors_one_day_ago, visitors_two_days_ago)
  end

  def message
    first_part, second_part = "", ""
    if @metric.yesterday?
      first_part = "GOV.UK had #{@metric.yesterday} visitors yesterday"
    end
    if @metric.delta?
      if @metric.delta == 0
        second_part = ", about the same as the day before"
      elsif @metric.increase?
        second_part = ", <green>an increase of #{@metric.delta}%</green> from the day before"
      else
        second_part = ", <red>a decrease of #{@metric.delta}%</red> from the day before"
      end
    end

    "#{first_part}#{second_part}"
  end
end

class VisitorsMetric
  def initialize(visitors_one_day_ago, visitors_two_days_ago)
    @yesterday = visitors_one_day_ago
    @the_day_before = visitors_two_days_ago
  end

  def yesterday?
    @yesterday != nil
  end

  def delta?
    @yesterday != nil and @the_day_before != nil
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

  def increase?
    @yesterday > @the_day_before
  end
end