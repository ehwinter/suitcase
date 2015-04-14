module Suitcase

  # holds one (of many) hotel images
  # see: hotel_info_request
  class HotelImage < ResponseObject

    attr_accessor :byte_size, :category, :height, :hotel_image_id, :supplier_id, :type, :width
    attr_accessor :caption, :name, :thumbnail_url, :url


    protected
    # HotelDetails ean fields
    def ean_fields(ean_format=true)
      ean_types = {integer: ["byteSize", "category", "height", "hotelImageId", "supplierId", "type", "width"],
        string: ["caption", "name", "thumbnailUrl", "url"],
        float: []}

      ean_types.each{|type, name_array| ean_types[type] = name_array.map{|k| Utils.rubyize_key(k)}.sort.flatten} if !ean_format
      ean_types
    end

  end
end