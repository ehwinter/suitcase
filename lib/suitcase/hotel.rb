module Suitcase
  # Public: Class for doing Hotel operations in the EAN API.
  class Hotel
    # Internal: List of possible amenities and their masks as returned by the
    #           API.
    AMENITIES = {
      business_center: 1,
      fitness_center: 2,
      hot_tub: 4,
      internet_access: 8,
      kids_activities: 16,
      kitchen: 32,
      pets_allowed: 64,
      swimming_pool: 128,
      restaurant: 256,
      spa: 512,
      whirlpool_bath: 1024,
      breakfast: 2048,
      babysitting: 4096,
      jacuzzi: 8192,
      parking: 16384,
      room_service: 32768,
      accessible_path: 65536,
      accessible_bathroom: 131072,
      roll_in_shower: 262144,
      handicapped_parking: 524288,
      in_room_accessibility: 1048576,
      deaf_accessiblity: 2097152,
      braille_or_raised_signage: 4194304,
      free_airport_shuttle: 8388608,
      indoor_pool: 16777216,
      outdoor_pool: 33554432,
      extended_parking: 67108864,
      free_parking: 134217728
    }

    class << self
      # Public: Find hotels matching the search query.
      #
      # There are two main types of queries. An availability search, which
      # requires dates, rooms, and a destination to search. The other is a
      # 'dateless' search, which finds all hotels in a given area.
      #
      # params - A Hash of search query parameters:
      #           :arrival            - String date of arrival, written
      #                                 MM/DD/YYYY (defult: nil).
      #           :departure          - String date of departure, written
      #                                 MM/DD/YYYY (default: nil).
      #           :number_of_results  - Number of results to return
      #                                 (default: 20). Does not apply to
      #                                 dateless requests.
      #           :rooms              - An Array of Hashes, within each Hash
      #                                 (default: nil):
      #                                 :adults   - Number of adults in the
      #                                             room.
      #                                 :children - Array of childrens' ages in
      #                                             the room. (default: [])
      #           :include_details    - Boolean. Include extra information with
      #                                 each room option.
      # Examples:
      #
      #   Hotel.find(location: "Boston")
      #   # => #<Result [all hotels in Boston as Hotel objects]>
      #
      #   Hotel.find(arrival: "03/14/2014", departure: "03/21/2014"
      #              location: "Boston", rooms: [{ adults: 1}])
      #   # => #<Result [all hotels in Boston with their rooms available from
      #                 14 Mar 2014 to 21 Mar 2014]>
      #
      # Returns a Result with the search results.
      def find(params)
        if params[:arrival]
          availability_search(params)
        else
          dateless_search(params)
        end
      end

      # Internal: Run an availability search for Hotels.
      #
      # params - A Hash of search query parameters, unchanged from the find
      #           method:
      #           :arrival            - String date of arrival, written MM/DD/YYYY.
      #           :departure          - String date of departure, written MM/DD/YYYY.
      #           :number_of_results  - Integer number of results to return.
      #           :rooms              - An Array of Hashes, within each Hash:
      #                                 :adults   - Integer number of adults in
      #                                             the room.
      #                                 :children - Array of childrens' Integer
      #                                             ages in the room.
      #           :include_details    - Boolean. Whether to include extra
      #                                 information with each room option.
      #
      # Returns a Result with search results.
      def availability_search(params)
        hotel_list(
          arrivalDate: params[:arrival],
          departureDate: params[:departure],
          numberOfResults: params[:number_of_results],
          RoomGroup: room_group(params[:rooms]),
          includeDetails: params[:include_details],
          includeHotelFeeBreakdown: true,
          destinationString: params[:location]
        )
      end

      # Internal: Run a 'dateless' search for Hotels.
      #
      # params - A Hash of search query parameters, generally just a location:
      #           :location - String user-inputted location.
      #
      # Returns a Result with search results.
      def dateless_search(params)
        hotel_list(destinationString: params[:location])
      end

      # Internal: Complete the request for a Hotel list.
      #
      # req_params - A Hash of search query parameters, as modified by the used
      #               search function:
      #               :arrivalDate              - String date of arrival
      #                                           (default: nil).
      #               :departureDate            - String date of departure
      #                                           (default: nil).
      #               :numberOfResults          - Integer number of Hotel
      #                                           results.
      #               :RoomGroup                - String. Formatted according to
      #                                           EAN API spec to describe
      #                                           desired rooms.
      #               :includeDetails           - Boolean. Whether to include
      #                                           extra details in each room
      #                                           option.
      #               :includeHotelFeeBreakdown - Boolean. Whether to include
      #                                           a room fee breakdown for each
      #                                           room option.
      #
      # Returns a Result with search results.
      def hotel_list(req_params)
        req_params[:cid] = Suitcase::Configuration.ean_hotel_cid
        req_params[:apiKey] = Suitcase::Configuration.ean_hotel_api_key
        req_params[:minorRev] = Suitcase::Configuration.ean_hotel_minor_rev

        req = Patron::Session.new
        params_string = req_params.inject("") do |initial, (key, value)|
          initial + if value
                      req.urlencode(key.to_s) + "=" + req.urlencode(value) + "&"
                    else
                      ""
                    end
        end
        req.timeout = 30
        req.base_url = "http://api.ean.com"
        res = req.get("/ean-services/rs/hotel/v3/list?#{params_string}")

        Result.new(res.url, req_params, res.body, parse_hotel_list(res.body))
      end

      # Internal: Parse the results of a Hotel list call.
      #
      # body - String body of the response from the call.
      #
      # Returns an Array of Hotels based on the search results.
      # Raises Suitcase::Hotel::EANEexception if the EAN API returns an error.
      def parse_hotel_list(body)
        root = JSON.parse(body)["HotelListResponse"]

        if error = root["EanWsError"]
          handle(error)
        else hotels = root["HotelList"]["HotelSummary"]
          hotels.map do |data|
            Hotel.new do |hotel|
              hotel.id = data["hotelId"]
              hotel.name = data["name"]
              hotel.address = data["address1"]
              hotel.address += data["address2"] if data["address2"]
              hotel.city = data["city"]
              hotel.province = data["stateProvinceCode"]
              hotel.postal = data["postalCode"]
              hotel.country = data["countryCode"]
              hotel.airport = data["airportCode"]
              hotel.category = data["propertyCategory"]
              hotel.rating = data["hotelRating"]
              hotel.confidence_rating = data["confidenceRating"]
              hotel.amenities = parse_amenities(data["amenityMask"])
              hotel.tripadvisor_rating = data["tripAdvisorRating"]
              hotel.location_description = data["locationDescription"]
              hotel.short_description = data["shortDescription"]
              hotel.high_rate = data["highRate"]
              hotel.low_rate = data["lowRate"]
              hotel.currency = data["rateCurrencyCode"]
              hotel.latitude = data["latitude"]
              hotel.longitude = data["longitude"]
              hotel.proximity_distance = data["promixityDistance"]
              hotel.proximity_unit = data["proximityUnit"]
              hotel.in_destination = data["hotelInDestination"]
              hotel.thumbnail_path = data["thumbNailUrl"]
              hotel.ian_url = data["deepLink"]
            end
          end
        end
      end
      
      # Internal: Parse the amenities of a Hotel.
      #
      # mask - Integer mask of the amenities.
      #
      # Returns an Array of Symbol amenities, as from the Hotel::Amenity Hash.
      def parse_amenities(mask)
        AMENITIES.select { |amenity, amask| (mask & amask) > 0 }.keys
      end
    end

    attr_accessor :id, :name, :address, :city, :province, :postal, :country,
                  :airport, :category, :rating, :confidence_rating,
                  :amenities, :tripadvisor_rating, :location_description,
                  :short_description, :high_rate, :low_rate, :currency,
                  :latitude, :longitude, :proximity_distance, :proximity_unit
                  :in_destination, :thumbnail_path, :ian_url

    # Internal: Create a new Hotel.
    #
    # block - Required. Should accept the hotel object itself to set attributes
    #         on.
    def initialize
      yield self
    end

    # Internal: A small wrapper around the results of an EAN API call.
    class Result
      attr_reader :url, :params, :raw, :parsed

      # Internal: Create a new Result.
      #
      # url     - String URL of the request.
      # params  - Hash of the params used in the request.
      # raw     - String, raw results of the request.
      # parsed  - Whatever parsed information is to be returned.
      def initialize(url, params, raw, parsed)
        @url, @params, @raw, @parsed = url, params, raw, parsed
      end
    end
  end
end
