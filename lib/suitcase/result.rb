module Suitcase
  # A small wrapper around the results of an EAN API call.
  class Result
    attr_reader :url, :params, :raw, :value

    # Internal: Create a new Result.
    #
    # url     - String URL of the request.
    # params  - Hash of the params used in the request.
    # raw     - String, raw results of the request.
    # value   - Whatever parsed information is to be returned.
    def initialize(url, params, raw, value)
      @url, @params, @raw, @value = url, params, raw, value
    end
  end
end