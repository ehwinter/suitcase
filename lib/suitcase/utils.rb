module Suitcase
  # method class for common utilities
  class Utils
    class << self
      # Internal: Return the base URL, based on whether it's a booking, secure,
      #           or development request.
      #
      # booking - Boolean. The request will be sent securely to "book.api.ean.co
      #           m."
      #
      # Returns a String URL for usage with the Patron base_url method.
      def base_url(booking=false)
        if Suitcase.configuration[:development]
          return "http://dev.api.ean.com"
        else
          if booking
            return "https://book.api.ean.com"
          else
            return "http://api.ean.com"
          end
        end
      end

      # most keys are stored as a snake case version of the EAN key name
      # e.g. hotelId => :hotel_id
      def rubyize_key(camel_case_key)
        camel_case_key.to_s.underscore.to_sym
      end

      # EAN keys come in three variants:
      # "lower" lower camel case (most typical) for request parameters and response attributes e.g. "stateProvinceCode"
      # "upper" upper camel case for response elements e.g. "HotelSummary" as in: HotelSummary.stateProvinceCode
      # "at"    at prefixed ( @ + lower cc) for attributes associated with elements e.g. "@size" for each array, "@hotelId" for superfluous hotel_id in HotelInfo
      def eanize_key(snake_case_key, ean_type="lower")
        if ean_type == "upper"
          snake_case_key.to_s.camelize(:upper)
        elsif ean_type == "at"
          "@" + snake_case_key.to_s.camelize(:lower)
        else
          snake_case_key.to_s.camelize(:lower)
        end
      end

      # Given EAN style request_params generate
      # params
      #           req_params - EAN style request params
      #           request_object - an empty Patron session object
      #           booking - true only if this is a booking request
      def provision_request(req_params, request_object, booking=false)
        req_params[:cid] = Suitcase.configuration[:cid]
        req_params[:apiKey] = Suitcase.configuration[:api_key]
        req_params[:minorRev] = Suitcase.configuration[:minor_rev]
        req_params[:apiExperience] = Suitcase.configuration[:api_experience]
        req_params = req_params.delete_if { |k, v| v == nil }

        params_string = req_params.map do |key, value|
          value = (value == true ? "true" : value)
          request_object.urlencode(key.to_s) + "=" + request_object.urlencode(value.to_s) if value
        end.compact.join("&")
        request_object.timeout = 30
        request_object.base_url = base_url(booking) # not a booking request
        params_string
      end

    end # selfless
  end
end