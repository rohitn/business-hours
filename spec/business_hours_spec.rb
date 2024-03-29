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

  it "returns the correct start and end times for the business day" do
    Time.zone = @time_zone
    Timecop.freeze(Time.local(2011, 11, 05, 13, 0, 0)) do # Sunday, November 5, 2011 at 1pm
      @business_time = BusinessHours.new({:times => @times, :time_zone => @time_zone, :business_day_start => @business_day_start}) 
    end
    @business_time.business_day.collect{|date| date.to_s}.should == ["2011-11-05 06:00:00 -0500","2011-11-06 06:00:00 -0600"]

    Timecop.freeze(Time.local(2011, 11, 06, 13, 0, 0)) do # Sunday, November 6, 2011 at 1pm
      @business_time = BusinessHours.new({:times => @times, :time_zone => @time_zone, :business_day_start => @business_day_start}) 
    end
    @business_time.business_day.collect{|date| date.to_s}.should == ["2011-11-06 06:00:00 -0600","2011-11-07 06:00:00 -0600"]

    Timecop.freeze(Time.local(2012, 03, 10, 13, 0, 0)) do # Saturday, March 10, 2012 at 1pm
      @business_time = BusinessHours.new({:times => @times, :time_zone => @time_zone, :business_day_start => 2}) 
    end
    @business_time.business_day.collect{|date| date.to_s}.should == ["2012-03-10 02:00:00 -0600","2012-03-11 03:00:00 -0500"]

    Timecop.freeze(Time.local(2012, 03, 11, 13, 0, 0)) do # Sunday, March 11, 2012 at 1pm
      @business_time = BusinessHours.new({:times => @times, :time_zone => @time_zone, :business_day_start => 2}) 
    end
    @business_time.business_day.collect{|date| date.to_s}.should == ["2012-03-11 03:00:00 -0500","2012-03-12 02:00:00 -0500"]

    Timecop.freeze(Time.local(2012, 03, 11, 13, 0, 0)) do # Sunday, March 11, 2012 at 1pm
      @business_time = BusinessHours.new({:times => @times, :time_zone => "Hawaii", :business_day_start => 2}) 
    end
    @business_time.business_day.collect{|date| date.to_s}.should == ["2012-03-11 03:00:00 -1000","2012-03-12 02:00:00 -1000"]

    business_hours = BusinessHours.new(:times => @times, :business_day_start => 1)
    business_hours.business_day(Date.parse('2012-04-05')).should == [Time.parse('2012-04-05 1:00:00 -0500'), Time.parse('2012-04-06 1:00:00 -0500')] # thursday 1:30 am

    business_hours = BusinessHours.new(:times => @times, :business_day_start => 2, :time_zone => 'Hawaii')
    business_hours.business_day(Date.parse('2012-04-07')).should == [Time.parse('2012-04-07 2:00:00 -1000'), Time.parse('2012-04-08 2:00:00 -1000')] # thursday 1:30 am

  end

  describe 'for_day' do
    it 'should return nil as an element of the return when the provided open_time or close_time was nil or emptystring' do
      business_hours = BusinessHours.new(:times => {:friday => ['',nil], :tuesday => ['9am', '']})
      business_hours.for_day(Date.parse('2012-03-19')).should == [nil,nil] #monday march 19th
      business_hours.for_day(Date.parse('2012-03-20')).should == [Time.parse('2012-03-20 9am'),nil] #tuesday march 20th
    end
  end
  describe 'open_past_midnight' do
    it 'should return nil when times is blank' do
      business_hours = BusinessHours.new
      business_hours.send(:open_past_midnight,1,'').should == nil
    end
  end
  describe 'open?' do
    it 'should return false if a day has no open or close time' do
      Timecop.freeze('2012-03-29 13:43:27 -0500') do #thursday
        business_hours = BusinessHours.new(:times => {:thursday_open => '9am'})
        business_hours.open?.should be_false
        business_hours = BusinessHours.new(:times => {:thursday_close => '10pm'})
        business_hours.open?.should be_false
        business_hours = BusinessHours.new(:times => {})
        business_hours.open?.should be_false
      end
    end
  end
  describe 'business_day' do
    it 'it should return the business day for today by default' do
      Timecop.freeze(Time.parse('2012-04-01 10:00:00 -0500')) do # april 1st, 10am
        business_hours = BusinessHours.new
        business_hours.business_day.should == [Time.parse('2012-04-01 06:00:00 -0500'), Time.parse('2012-04-02 06:00:00 -0500')]
      end
    end
    it 'should return the business_day of the business_date specified' do
      business_hours = BusinessHours.new
      business_hours.business_day(Date.parse('2012-04-10')).should == [Time.parse('2012-04-10 06:00:00 -0500'), Time.parse('2012-04-11 06:00:00 -0500')]
    end
  end
  describe 'open_on_day?' do
    it 'should return true when there is an open and a close time for today' do
      business_hours = BusinessHours.new(:times => {:sunday => ['1pm','2pm']})
      business_hours.open_on_day?(Date.parse('2012-04-01')).should be_true
    end
    it "should return false when either the open time or close time for today is missing" do
      business_hours = BusinessHours.new(:times => {:sunday => ['1pm',nil]})
      business_hours.open_on_day?(Date.parse('2012-04-01')).should be_false
    end
    it 'should return false when there are no times for today' do
      business_hours = BusinessHours.new
      business_hours.open_on_day?(Date.parse('2012-04-01')).should be_false
    end
  end
  describe 'open_today?' do
    it 'should return true when there is an open and a close time for today' do
      Timecop.freeze(Time.parse('2012-04-02 06:00:00 -0500')) do #monday
        business_hours = BusinessHours.new(:times => {:monday => ['1pm','2pm']})
        business_hours.open_today?.should be_true
      end
    end
    it "should return false when either the open time or close time for today is missing" do
      Timecop.freeze(Time.parse('2012-04-02 06:00:00 -0500')) do #monday
        business_hours = BusinessHours.new(:times => {:monday => ['1pm',nil]})
        business_hours.open_today?.should be_false
      end
    end
    it 'should return false when there are no times for today' do
      Timecop.freeze(Time.parse('2012-04-02 06:00:00 -0500')) do #monday
        business_hours = BusinessHours.new
        business_hours.open_today?.should be_false
      end
    end
    it 'should return true even if it is 1am, the next date, but the same business day' do
      Timecop.freeze(Time.parse('2012-04-03 01:00:00 -0500')) do #tuesday, 1am
        business_hours = BusinessHours.new(:times => {:monday => ['2pm', '12:30am']})
        business_hours.open_today?.should be_true
      end
    end
    it 'should return false if given business hours for monday but the current time is 7am the next day' do
      Timecop.freeze(Time.parse('2012-04-03 07:00:00 -0500')) do #tuesday, 1am
        business_hours = BusinessHours.new(:times => {:monday => ['2pm', '12:30am']})
        business_hours.open_today?.should be_false
      end
   end
  end
end
