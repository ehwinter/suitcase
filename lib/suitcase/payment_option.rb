module Suitcase

  # Payment Options for a given currency code
  class PaymentOption
    attr_accessor :code, :name

    # Internal: Create a PaymentOption.
    #
    # code - The String code from the API response (e.g. "VI").
    # name - The String name of the PaymentOption.
    def initialize(code, name)
      @code, @name = code, name
    end

    # Public: Find PaymentOptions for a specific currency.
    #
    # info - A Hash containing :currency_code, :locale.
    # e.g. "USD", "en_US"
    #
    # Returns an Array of PaymentOption's.
    def self.find(payment_hash)
      req_params = {}
      req_params[:currencyCode] = payment_hash[:currency_code]
      req_params[:locale] = payment_hash[:locale]
      req = Patron::Session.new
      req.timeout = 30
      req.base_url = base_url(false) # not a booking request
      res = req.get("/ean-services/rs/hotel/v3/paymentInfo?#{query_string(req, req_params)}")
      Result.new(res.url, req_params, res.body, parse_hotel_list(res.body))
    end

    def self.query_string(req, req_params)
      req_params.map do |key, value|
        value = (value == true ? "true" : value)
        req.urlencode(key.to_s) + "=" + req.urlencode(value.to_s) if value
      end.compact.join("&")
    end
  end
end
