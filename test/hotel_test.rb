require "minitest_helper"

describe Suitcase::Hotel do
  describe "dateless list" do
    before :each do
      @result = Suitcase::Hotel.find(location: "Boston")
    end

    it "returns an Hotel::Result" do
      @result.must_be_kind_of Suitcase::Hotel::Result
    end

    it "offers the raw response" do
      @result.raw.wont_be_nil
    end

    it "offers the URL used to fetch the response" do
      @result.url.wont_be_nil
    end

    it "includes an Array of Hotel objects" do
      h = @result.value
      h.must_be_kind_of Array
      types = h.map { |o| o.class }.uniq
      types.length.must_equal 1
      types.first.must_equal Suitcase::Hotel
    end

    describe "room method through API request" do
      before :each do
        arrival = Chronic.parse('1 month from now').strftime('%m/%d/%Y')
        departure = Chronic.parse('5 weeks from now').strftime('%m/%d/%Y')
        @hotel = @result.value.first
        @result = @hotel.rooms(arrival: arrival, departure: departure,
                              rooms: [{ adults: 1 }])
      end

      it "returns a Suitcase::Hotel::Room::Result" do
        @result.must_be_kind_of Suitcase::Hotel::Room::Result
      end

      it "takes an options list" do
        result = @hotel.rooms(arrival: arrival, departure: departure,
                              rooms: [{ adults: 1 }], options: [:hotel_details])
        result.hotel_details.wont_be_nil
      end
    end
  end

  describe "availability search" do
    before :each do
      arrival = Chronic.parse('1 month from now').strftime('%m/%d/%Y')
      departure = Chronic.parse('5 weeks from now').strftime('%m/%d/%Y')
      @result = Suitcase::Hotel.find(
        arrival: arrival,
        departure: departure,
        location: "Boston",
        rooms: [{ adults: 1 }],
        include_details: true # necessary for two-step reservation
      )
    end

    it "returns a Hotel::Result" do
      @result.must_be_kind_of Suitcase::Hotel::Result
    end

    it "offers the raw response" do
      @result.raw.wont_be_nil
    end

    it "offers the URL used to fetch the response" do
      @result.url.wont_be_nil
    end

    it "includes an Array of Hotel objects" do
      h = @result.value
      h.must_be_kind_of Array
      types = h.map { |o| o.class }.uniq
      types.length.must_equal 1
      types.first.must_equal Suitcase::Hotel
    end
  end

  describe "error handling" do
    before :each do
      begin
        Suitcase::Hotel.find(location: "Some invalid location")
      rescue Suitcase::Hotel::EANException => e
        @exception = e
      end
    end

    it "should raise an exception" do
      assert_raises(Suitcase::Hotel::EANException) do
        Suitcase::Hotel.find(location: "No such place exists")
      end
    end

    it "should set the raw API results on the Exception" do
      @exception.raw.wont_be_nil
    end

    it "offers the verbose API message" do
      @exception.verbose_message.wont_be_nil
    end

    it "offers the recoverability of the error" do
      @exception.recoverability.wont_be_nil
    end
  end
end

