module Suitcase

  # Request provides all needed detail for a single hotel
  class HotelInfoRequest

    attr_accessor :result

    attr_accessor :hotel_details, :hotel_images, :hotel_summary, :property_amenities, :room_types, :suppliers

    def self.parse_info(body)
      parsed = {}
      root = JSON.parse(body)["HotelInformationResponse"]
      if root
        parsed[:hotel_images] = HotelImage.images(root["HotelImages"]) if root["HotelImages"]
      end
      parsed
    end

    # Make the HotelInformationRequest
    # usage result = Suitcase::HotelImage.info_request
    #
    # ruby_req_params - A Hash of search query parameters (ruby style)
    #           :hotel_id   - integer 106347
    #
    # Returns a Result object:  containing the response and parsed version of it
    def self.request(ruby_req_params={hotel_id: 106347})
      req_params={}
      req = Patron::Session.new
      ruby_req_params.each{|k,v| req_params[Utils.eanize_key(k)] = v}
      params_string = Utils.provision_request(req_params,req)
      res = req.get("/ean-services/rs/hotel/v3/info?#{params_string}")
      Result.new(res.url, req_params, res.body, parse_info(res.body))
    end

    # creates a new instance: makes the request and parses it.
    def initialize(ruby_req_params)
      if ruby_req_params
        @result = self.class.request(ruby_req_params)
        @hotel_images = @result.value[:hotel_images]
      end
    end

    private
    # cheap way of generating attr_accessor list. copy/pasted from API
    def ruby_fields
      ean_keys = ["@hotelId",
       "customerSessionId",
       "HotelSummary",
       "HotelDetails",
       "Suppliers",
       "RoomTypes",
       "PropertyAmenities",
       "HotelImages"]
      ean_keys.map{|k| Utils.rubyize_key(k)}.sort.flatten
    end


  end
end
