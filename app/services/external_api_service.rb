class ExternalApiService
  OPEN_TIMEOUT = ENV.fetch('EXTERNAL_API_OPEN_TIMEOUT', 5).to_i  # seconds
  READ_TIMEOUT = ENV.fetch('EXTERNAL_API_READ_TIMEOUT', 10).to_i # seconds
  MAX_RETRIES = ENV.fetch('EXTERNAL_API_MAX_RETRIES', 3).to_i

  def initialize
    @connection = Faraday.new do |conn|
      conn.options.open_timeout = OPEN_TIMEOUT
      conn.options.timeout = READ_TIMEOUT
      conn.adapter Faraday.default_adapter
    end
  end

  def fetch_with_resilience(url)
    attempt = 0
    begin
      attempt += 1
      response = @connection.get(url)
      parse_response(response)
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
      if attempt < MAX_RETRIES
        sleep(backoff_time(attempt))
        retry
      else
        log_failure(e, url, attempt)
        fallback_response
      end
    end
  end

  private

  def backoff_time(attempt)
    2 ** attempt  # Exponential: 2s, 4s, 8s
  end

  def log_failure(error, url, attempt)
    Rails.logger.error("External API call failed after #{attempt} attempts")
    Rails.logger.error("URL: #{url}")
    Rails.logger.error("Error: #{error.class} - #{error.message}")
  end

  def parse_response(response)
    if response.success?
      { success: true, data: JSON.parse(response.body) }
    else
      { success: false, data: fallback_response }
    end
  end

  def fallback_response
    raise NotImplementedError, "Subclasses must implement fallback_response method"
  end
end
