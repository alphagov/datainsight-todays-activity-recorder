class DateTime
  def to_midnight
    to_full_hour(0)
  end

  def to_full_hour(hour)
    DateTime.new(year, month, day, hour, 0, 0, zone)
  end
end