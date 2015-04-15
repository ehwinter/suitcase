module Suitcase

  # Request provides all needed detail for a single hotel
  class HotelInfoRequest < EanRequest

    attr_accessor :hotel_details, :hotel_images, :hotel_summary, :property_amenities, :room_types, :suppliers
    attr_accessor :hotel_id
    attr_accessor :customer_session_id

    def self.response_object_name
      "HotelInformationResponse"
    end

    def self.request_specific_parse(root)
      parsed={}
      if root
        parsed[:hotel_images] =            HotelImage.array_parse(root["HotelImages"]) if root["HotelImages"]
        parsed[:property_amenities] = PropertyAmenity.array_parse(root["PropertyAmenities"]) if root["PropertyAmenities"]
        parsed[:hotel_details] = HotelDetails.new(root["HotelDetails"]) if root["HotelDetails"]
        parsed[:hotel_summary] = HotelSummary.new(root["HotelSummary"]) if root["HotelSummary"]
        parsed[:customer_session_id] = root[Utils.eanize_key(:customer_session_id)]
        parsed
      end
    end

    # creates a new instance: makes the request and parses it.
    def initialize(ruby_req_params={hotel_id: 106347})
      super(ruby_req_params)
      if ruby_req_params
        @hotel_images = @result.value[:hotel_images]
        @property_amenities = @result.value[:property_amenities]
        @hotel_details = @result.value[:hotel_details]
        @hotel_summary = @result.value[:hotel_summary]
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
