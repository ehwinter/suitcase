module Suitcase

  # Lookup existing itineraries/reservations.
  # Can search by create date, itinerary id, credit card/last name etc.
  # Very flexible search criteria
  # initial implementation
  class ItineraryRequest < EanRequest

    # an optional input to the itinerary request
    class ItineraryQuery < ResponseObject
      protected
      # Override for each subclass
      def ean_fields(ean_format=true)
        ean_types = {float: [],
          integer: [],
          string: %w(creationDateEnd creationDateStart departureDateEnd departureDateStart)}

        ean_types.each{|type, name_array| ean_types[type] = name_array.map{|k| Utils.rubyize_key(k)}.sort.flatten} if !ean_format
        ean_types
      end
    end

    attr_accessor :itinerary_query

    # by default you will want JSON.parse(body)["HotelInformationResponse"] i.e. this class' name
    def self.relative_uri(query_string)
      "/ean-services/rs/hotel/v3/itin?#{query_string}"
    end

    def self.response_object_name
      "HotelItineraryResponse"
    end

    # creates a new instance: makes the request and parses it.
    def initialize(ruby_req_params={creation_date_start: (Date.today - 7.days).iso8601, creation_date_end: Date.today.iso8601 })
      super(ruby_req_params)
    end

  end
end
