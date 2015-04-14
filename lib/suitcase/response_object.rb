module Suitcase

  # Generic superclass for EAN REST response content.
  # the EAN response is in lower camel case, those are converted to snake case ruby symbols
  # note: a response may contain one or more distinct ResponseObject.
  class ResponseObject

    # ean_response_object - Hash, parsed JSON from the EAN response containing only this object
    #   e.g. the HotelSummary object should get ean_response_object == parsed_response["HotelSummary"]
    #
    def initialize(ean_response_object)
      ean_response_object.select{|k,v| attribute_names(false,:integer).include?(k)}.each do |k,v|
        send(Utils.rubyize_key(k).to_s+"=",v.to_i) if v
      end
      ean_response_object.select{|k,v| attribute_names(false,:string).include?(k)}.each do |k,v|
        send(Utils.rubyize_key(k).to_s+"=",v) if v && !v.empty?
      end
      ean_response_object.select{|k,v| attribute_names(false,:float).include?(k)}.each do |k,v|
        send(Utils.rubyize_key(k).to_s+"=",v.to_f) if v
      end
    end

    # If the EAN Response has a collection of ResponseObjects e.g. a list of amenities,
    # then this is used and an array of objects of this class is returned
    #
    # params
    #     parsed
    #     collection_key String the value associated with this key is the array to be parsed
    #     item_klass Class to be constructed n times
    def self.array_parse(ean_response_collection_object)
      parsed_items = ean_response_collection_object[collection_key].map do |item|
        self.new(item)
      end if ean_response_collection_object && ean_response_collection_object[collection_key]
      parsed_items || []
    end

    # typically the class name without the module
    def self.collection_key
      self.name.demodulize
    end

    # this classes attributes grouped by data type
    # params
    #           type symbol, :integer, :string, :float
    #           ruby_format, boolean, true => snake case symbold, false => EAN camel case strings
    # Returns array of the requested type in the requested format
    def attribute_names(ruby_format, type)
      if ruby_format
        ean_fields[type].map!{|name| Utils.rubyize_key(name)}
      else
        ean_fields[type]
      end
    end

    protected
    # Override for each subclass
    def ean_fields(ean_format=true)
      ean_types = {float: %w(hotelRating latitude longitude),
        integer: %w(propertyCategory hotelId),
        string: %w(address1 airportCode city countryCode highRate locationDescription lowRate name postalCode rateCurrencyCode stateProvinceCode)}

      ean_types.each{|type, name_array| ean_types[type] = name_array.map{|k| Utils.rubyize_key(k)}.sort.flatten} if !ean_format
      ean_types
    end

  end
end