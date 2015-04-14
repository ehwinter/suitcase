module Suitcase

  # holds one (of many) hotel images
  # see: hote_info_request
  class PropertyAmenity < ResponseObject

    # integers
    attr_accessor :amenity_id
    # string
    attr_accessor :amenity

    protected
    # HotelSummary ean fields
    def ean_fields(ean_format=true)
      ean_types = {float: [],
        integer: %w(amenityId),
        string: %w(amenity)}

      ean_types.each{|type, name_array| ean_types[type] = name_array.map{|k| Utils.rubyize_key(k)}.sort.flatten} if !ean_format
      ean_types
    end

  end
end