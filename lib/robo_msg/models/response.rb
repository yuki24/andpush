module RoboMsg
  class Response
    attr_reader :multicast_id, :success, :failure, :canonical_ids, :results

    def initialize(multicast_id: nil, success: nil, failure: nil, canonical_ids: nil, results: nil)
      @multicast_id = multicast_id
      @success = success
      @failure = failure
      @canonical_ids = canonical_ids
      @results = results
    end
  end
end
