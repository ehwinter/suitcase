module Suitcase

  # mainly descriptive content, some in HTML
  # NOT a collection
  class HotelDetails < ResponseObject

    #integer
    attr_accessor :number_of_floors, :number_of_rooms
    # string
    attr_accessor :amenities_description, :area_information, :business_amenities_description, :check_in_instructions, :check_in_time, :check_out_time, :deposit_credit_cards_accepted, :dining_description, :driving_directions, :hotel_policy, :know_before_you_go_description, :location_description, :mandatory_fees_description, :national_ratings_description, :native_currency_code, :property_description, :property_information, :renovations_description, :room_detail_description, :room_fees_description, :room_information


    protected
    # HotelDetail ean fields
    def ean_fields(ean_format=true)
      ean_types = {integer: %w(numberOfFloors numberOfRooms),
        string: %w(amenitiesDescription areaInformation businessAmenitiesDescription checkInInstructions checkInTime checkOutTime depositCreditCardsAccepted diningDescription drivingDirections hotelPolicy knowBeforeYouGoDescription locationDescription mandatoryFeesDescription nationalRatingsDescription nativeCurrencyCode  propertyDescription propertyInformation renovationsDescription roomFeesDescription roomInformation roomDetailDescription),
        float: []}

      ean_types.each{|type, name_array| ean_types[type] = name_array.map{|k| Utils.rubyize_key(k)}.sort.flatten} if !ean_format
      ean_types
    end

  end
end