module Suitcase

  # holds one (of many) hotel images
  # see: hote_info_request
  class HotelSummary < ResponseObject

    # float
    attr_accessor :high_rate, :hotel_rating, :latitude, :longitude, :low_rate
    # integers
    attr_accessor :hotel_id, :property_category
    # string
    attr_accessor :address1, :airport_code, :city, :country_code, :location_description, :name, :postal_code, :rate_currency_code, :state_province_code


    protected
    # HotelSummary ean fields
    def ean_fields(ean_format=true)
      ean_types = {float: %w(highRate hotelRating latitude longitude lowRate),
        integer: %w(propertyCategory hotelId),
        string: %w(address1 airportCode city countryCode locationDescription name postalCode rateCurrencyCode stateProvinceCode)}

      ean_types.each{|type, name_array| ean_types[type] = name_array.map{|k| Utils.rubyize_key(k)}.sort.flatten} if !ean_format
      ean_types
    end

  end
end