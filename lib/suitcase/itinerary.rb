module Suitcase

  # Request provides all needed detail for a single hotel
  class Itinerary < ResponseObject
    # String
    attr_accessor :affiliate_confirmation_id, :api_experience, :credit_card_number, :email, :last_name
    #integer
    attr_accessor :itinerary_id


    # Override for each subclass
    def ean_fields(ean_format=true)
      ean_types = {float: [],
        integer: %w(itineraryId),
        string: %w(affiliateConfirmationId apiExperience creditCardNumber email lastName)}

      ean_types.each{|type, name_array| ean_types[type] = name_array.map{|k| Utils.rubyize_key(k)}.sort.flatten} if !ean_format
      ean_types
    end

  end
end
