require "business-hours/version"

class BusinessHours
  require 'chronic'
  
  attr_accessor :times, :time_zone, :business_date, :business_day_start
  DAYS = %w(sunday monday tuesday wednesday thursday friday saturday)
  
  # Valid options: :times, :time_zone, :business_date, :business_day_start
  #   :times => must be a Hash with an Array of time (example: { :sunday => [Time.now, Time.now + 10.hours] }). Defaults to an empty hash.
  #   :time_zone => must be a time zone string. Defaults to Central Time.
  #   :business_date => must be a Date object. Defaults to the business date determined by the lib.
  #   :business_day_start => the hour the business day flips over. Defaults to app config.
  def initialize(options = {})
    @times = options[:times] || {}
    @time_zone = options[:time_zone] || "Central Time (US & Canada)"
    @business_date = options[:business_date] || BusinessHours.business_date(options)
    @business_day_start = options[:business_day_start] || 6
    
    Time.zone = @time_zone
  end
  
  def open?(options = {})
    current_time = options[:current_time] || Time.zone.now
    times = for_today

    times[0] <= current_time and current_time <= times[1]
  end
  
  def for_today
    for_day(@business_date)
  end
  
  def for_day(date)
    raise ArgumentError.new("Not a valid Date object") if date.class != Date
    
    times = times_for_date(date)
    
    if open_past_midnight(date.wday, times)
      close_day = date.tomorrow
    else
      close_day = date
    end
    
    open_day = date
    
    [parse("#{open_day} #{times[0]}"), parse("#{close_day} #{times[1]}")]
  end
  
  def self.business_date(options = {})
    business_day_start = options[:business_day_start] || 6
    Time.zone = options[:time_zone] || @time_zone
    current_time = options[:current_time] || Time.zone.now
    
    business_date = current_time.hour < business_day_start ? Time.zone.today - 1 : Time.zone.today
  end
  
  private
    def times_for_date(date)
      @times[get_day(date.wday).to_sym]
    end
    
    def open_past_midnight(day, times)
      day = get_day(day)
      open = parse("#{day} #{times[0]}")
      close = parse("#{day} #{times[1]}")
      
      open > close
    end
    
    def get_day(day_int = 0)
      DAYS[day_int]
    end
    
    def parse(string)
      Chronic.time_class = Time.zone
      Chronic.parse(string)
    end
end
