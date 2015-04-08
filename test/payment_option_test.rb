require "minitest_helper"

describe Suitcase::PaymentOption do

  describe "with invalid requests" do
    it "fails without currency code" do
      @result = Suitcase::PaymentOption.find({locale: "en_US"})
      @result.raw.wont_be_nil
    end
    it "fails without locale" do
      @result = Suitcase::PaymentOption.find({currency_code: "USD"})
      @result.raw.wont_be_nil
    end
  end

  describe "valid payment optionrequests" do
    before :each do
      @result = Suitcase::PaymentOption.find({currency_code: "USD", locale: "en_US"})
    end
    it "returns payment options" do
      @result.raw.wont_be_nil
      @result.value.wont_be_nil
      @result.value.first.class.must_equal Suitcase::PaymentOption
      @result.value.first.code.wont_be_nil
    end
  end
end
