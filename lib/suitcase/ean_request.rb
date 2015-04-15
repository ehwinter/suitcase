module Suitcase

  # generic superclass for request classes
  # typically name subclass by the full name of the request (the key in the response JSON)
  class EanRequest

    attr_accessor :result

    # Make the HotelInformationRequest
    # usage result = Suitcase::HotelImage.info_request
    #
    # ruby_req_params - A Hash of search query parameters (ruby style)
    #           :hotel_id   - integer 106347
    #
    # Returns a Result object:  containing the response and parsed version of it
    def self.request(ruby_req_params={})
      req_params={}
      req = Patron::Session.new
      ruby_req_params.each{|k,v| req_params[Utils.eanize_key(k)] = v}
      query_string = Utils.provision_request(req_params,req)
      res = req.get(self.relative_uri(query_string))
      Result.new(res.url, req_params, res.body, self.parse(res.body))
    end

    # parse the JSON response string.
    # Override in subclass
    def self.parse(body)
      parsed = {}
      root = JSON.parse(body)[self.response_object_name]
      if root
        parsed = self.request_specific_parse(root)
      end
      parsed
    end


    def self.request_specific_parse(root)
      root
    end

    # Override if the class name differs from the JSON key e.g. JSON.parse(body)["HotelInformationResponse"] i.e. this class' name
    def self.response_object_name
      self.name.demodulize
    end

    # by default you will want JSON.parse(body)["HotelInformationResponse"] i.e. this class' name
    def self.relative_uri(query_string)
      "/ean-services/rs/hotel/v3/info?#{query_string}"
    end

    # creates a new instance: makes the request and parses it.
    def initialize(ruby_req_params)
      if ruby_req_params
        @result = self.class.request(ruby_req_params)
      end
    end

  end
end
