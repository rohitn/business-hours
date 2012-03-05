require 'spec_helper'

describe BusinessHours do

  before(:each) do
    @business_day_start = 6
    @time_zone = "Central Time (US & Canada)"
  end

  it "is within valid business hours .open? should return true" do
    @times = {:sunday => ["6:00am","6:00am"]}
    Timecop.freeze(Time.local(2011, 11, 06, 13, 0, 0)) do # Sunday, November 6, 2011 at 1pm
      BusinessHours.new({:times => @times, :time_zone => @time_zone, :business_day_start => @business_day_start}).open?.should_not be_true
    end

    @times = {:sunday => ["11:00am","2:00am"]}
    Timecop.freeze(Time.local(2011, 11, 06, 13, 0, 0)) do # Sunday, November 6, 2011 at 1pm
      BusinessHours.new({:times => @times, :time_zone => @time_zone, :business_day_start => @business_day_start}).open?.should be_true
    end

    @times = {:sunday => ["11:00am","12:00am"]}
    Timecop.freeze(Time.local(2011, 11, 06, 13, 0, 0)) do # Sunday, November 6, 2011 at 1pm
      BusinessHours.new({:times => @times, :time_zone => @time_zone, :business_day_start => @business_day_start}).open?.should be_true
    end

    @times = {:sunday => ["8:00am","6:00am"]}
    Timecop.freeze(Time.local(2011, 11, 06, 13, 0, 0)) do # Sunday, November 6, 2011 at 1pm
      BusinessHours.new({:times => @times, :time_zone => @time_zone, :business_day_start => @business_day_start}).open?.should be_true
    end

    @times = {:sunday => ["6:00am","5:59am"]}
    Timecop.freeze(Time.local(2011, 11, 06, 13, 0, 0)) do # Sunday, November 6, 2011 at 1pm
      BusinessHours.new({:times => @times, :time_zone => @time_zone, :business_day_start => @business_day_start}).open?.should be_true
    end

    @times = {
      :sunday => ["11:00am","12:59am"], 
      :monday=>["5:00pm", "2:00am"], 
      :tuesday=>["5:00pm", "2:00am"], 
      :wednesday=>["", ""], 
      :thursday=>["5:00pm", "2:00am"], 
      :friday=>["5:00pm", "2:00am"], 
      :saturday=>["11:00am", "3:00am"]
    }
    Timecop.freeze(Time.local(2012, 03, 04, 13, 0, 0)) do # Sunday, March 4, 2012 at 1pm
      BusinessHours.new({:times => @times, :time_zone => @time_zone, :business_day_start => @business_day_start}).open?.should be_true
    end
  end
end