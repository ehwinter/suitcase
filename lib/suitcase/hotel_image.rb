module Suitcase

  # holds one (of many) hotel images
  # see: hote_info_request
  class HotelImage

    attr_accessor :byte_size, :category, :height, :hotel_image_id, :supplier_id, :type, :width
    attr_accessor :caption, :name, :thumbnail_url, :url

    # Internal: Get images from the parsed JSON.
    #
    # parsed - Hash, parsed JSON from the EAN response. Only the hotel_images (subset) is passed.
    #
    # Returns an Array of HotelImages.
    def self.images(parsed)
      images = parsed["HotelImage"].map do |image_data|
        HotelImage.new(image_data)
      end if parsed && parsed["HotelImage"]
      images || []
    end

    # create using properties from the parsed JSON for a single image
    def initialize(ean_options)
      ean_options.select{|k,v| attribute_names(false,:integer).include?(k)}.each do |k,v|
        send(Utils.rubyize_key(k).to_s+"=",v.to_i) if v
      end
      ean_options.select{|k,v| attribute_names(false,:string).include?(k)}.each do |k,v|
        send(Utils.rubyize_key(k).to_s+"=",v) if v && !v.empty?
      end
    end

    private
    # params
    #           type symbol, :integer, :string
    #           ruby_format, boolean, true if snake case else EAN camel case
    def attribute_names(ruby_format, type)
      names = type == :integer ? [:byte_size, :category, :height, :hotel_image_id, :supplier_id, :type, :width] : []
      names = [:caption, :name, :thumbnail_url, :url] if type == :string
      unless ruby_format
        names.map!{|name| Utils.eanize_key(name)}
      end
      names.map(&:to_s)
    end

  end
end