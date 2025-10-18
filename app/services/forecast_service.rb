# frozen_string_literal: true

# ForecastService
#
# Service class responsible for retrieving weather forecast data from external APIs.
# Implements the Service Object pattern to encapsulate business logic.
#
# Design Patterns:
# - Service Object Pattern: Encapsulates complex business logic
# - Adapter Pattern: Abstracts external API interaction
# - Strategy Pattern: Can be extended to support multiple weather API providers
#
# Responsibilities:
# - Geocode addresses to coordinates
# - Fetch weather data from external API
# - Handle API errors gracefully
# - Return structured forecast data
#
# Dependencies:
# - HTTParty: HTTP client for API requests
# - Geocoder: Address to coordinates conversion
#
# Scalability Considerations:
# - Uses caching at controller level to reduce API calls
# - Implements error handling to prevent cascading failures
# - Can be extended with circuit breaker pattern for API resilience
#
# Example usage:
#   service = ForecastService.new
#   result = service.fetch_forecast_by_address("123 Main St, San Francisco, CA 94102")
#   if result[:success]
#     puts result[:data][:current_temp]
#   else
#     puts result[:error]
#   end
class ForecastService
  include HTTParty

  # Weather API configuration
  # Using weather.gov API (National Weather Service) - no API key required
  # Alternative: OpenWeatherMap API (requires API key)
  BASE_URL = 'https://api.weather.gov'

  # Constructor
  # Initializes the service with optional configuration
  def initialize
    @timeout = 10 # seconds
  end

  # Fetch forecast data by address
  #
  # @param address [String] Full address to get forecast for
  # @return [Hash] Result hash with :success, :data, and optional :error keys
  #
  # Response structure:
  # {
  #   success: true/false,
  #   data: {
  #     location: String,
  #     zip_code: String,
  #     current_temp: Float,
  #     high_temp: Float,
  #     low_temp: Float,
  #     conditions: String,
  #     forecast_short: String,
  #     forecast_detailed: String,
  #     timestamp: Time
  #   },
  #   error: String (only if success: false)
  # }
  def fetch_forecast_by_address(address)
    # Step 1: Validate input
    return error_response('Address cannot be blank') if address.blank?

    # Step 2: Geocode address to coordinates
    geocode_result = geocode_address(address)
    return geocode_result unless geocode_result[:success]

    coordinates = geocode_result[:data]

    # Step 3: Fetch weather data from API
    fetch_weather_data(coordinates)
  rescue StandardError => e
    # Handle unexpected errors gracefully
    Rails.logger.error("ForecastService error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    error_response("Failed to fetch forecast: #{e.message}")
  end

  # Fetch forecast data by zip code
  #
  # @param zip_code [String] 5-digit US zip code
  # @return [Hash] Result hash with :success, :data, and optional :error keys
  def fetch_forecast_by_zip(zip_code)
    # Validate zip code format
    return error_response('Invalid zip code format') unless valid_zip_code?(zip_code)

    # Use zip code as address for geocoding
    fetch_forecast_by_address(zip_code)
  end

  private

  # Geocode address to latitude/longitude coordinates
  #
  # @param address [String] Address to geocode
  # @return [Hash] Result hash with success and data/error
  def geocode_address(address)
    results = Geocoder.search(address)

    if results.empty?
      return error_response('Address not found. Please provide a valid US address.')
    end

    result = results.first
    
    # Extract location information
    {
      success: true,
      data: {
        latitude: result.latitude,
        longitude: result.longitude,
        formatted_address: result.address,
        zip_code: extract_zip_code(result)
      }
    }
  rescue Geocoder::Error => e
    Rails.logger.error("Geocoding error: #{e.message}")
    error_response('Failed to geocode address. Please try again.')
  end

  # Extract zip code from geocoder result
  #
  # @param result [Geocoder::Result] Geocoder result object
  # @return [String] Extracted zip code or 'Unknown'
  def extract_zip_code(result)
    # Try to extract zip code from address components
    if result.respond_to?(:postal_code)
      result.postal_code
    elsif result.respond_to?(:zip_code)
      result.zip_code
    else
      # Try to extract from formatted address
      address = result.address
      zip_match = address.match(/\b\d{5}(?:-\d{4})?\b/)
      zip_match ? zip_match[0] : 'Unknown'
    end
  end

  # Fetch weather data from National Weather Service API
  #
  # @param coordinates [Hash] Hash containing :latitude and :longitude
  # @return [Hash] Result hash with weather data
  def fetch_weather_data(coordinates)
    lat = coordinates[:latitude]
    lon = coordinates[:longitude]

    # Step 1: Get the forecast office and grid coordinates
    points_url = "#{BASE_URL}/points/#{lat},#{lon}"
    points_response = HTTParty.get(points_url, timeout: @timeout)

    unless points_response.success?
      return error_response('Unable to get forecast data for this location')
    end

    properties = points_response.parsed_response['properties']
    forecast_url = properties['forecast']
    forecast_hourly_url = properties['forecastHourly']

    # Step 2: Get the forecast data
    forecast_response = HTTParty.get(forecast_url, timeout: @timeout)
    
    unless forecast_response.success?
      return error_response('Failed to retrieve forecast data')
    end

    # Step 3: Get hourly forecast for current temperature
    hourly_response = HTTParty.get(forecast_hourly_url, timeout: @timeout)

    # Step 4: Parse and structure the response
    parse_forecast_response(
      forecast_response.parsed_response,
      hourly_response.success? ? hourly_response.parsed_response : nil,
      coordinates
    )
  rescue HTTParty::Error, Net::OpenTimeout => e
    Rails.logger.error("Weather API error: #{e.message}")
    error_response('Weather service is temporarily unavailable')
  end

  # Parse forecast response into structured format
  #
  # @param forecast_data [Hash] Forecast API response
  # @param hourly_data [Hash] Hourly forecast API response
  # @param coordinates [Hash] Location coordinates and metadata
  # @return [Hash] Structured forecast data
  def parse_forecast_response(forecast_data, hourly_data, coordinates)
    periods = forecast_data['properties']['periods']
    
    # Get current/first period
    current_period = periods[0]
    
    # Find today's high and low
    today_periods = periods.take(2) # Usually includes day and night
    high_temp = today_periods.map { |p| p['temperature'] }.max
    low_temp = today_periods.map { |p| p['temperature'] }.min

    # Get current temperature from hourly if available
    current_temp = if hourly_data && hourly_data['properties']
                    hourly_data['properties']['periods'].first['temperature']
                  else
                    current_period['temperature']
                  end

    # Build extended forecast (next 7 periods)
    extended_forecast = periods.take(7).map do |period|
      {
        name: period['name'],
        temperature: period['temperature'],
        temperature_unit: period['temperatureUnit'],
        conditions: period['shortForecast'],
        detailed_forecast: period['detailedForecast'],
        wind_speed: period['windSpeed'],
        wind_direction: period['windDirection']
      }
    end

    {
      success: true,
      data: {
        location: coordinates[:formatted_address],
        zip_code: coordinates[:zip_code],
        latitude: coordinates[:latitude],
        longitude: coordinates[:longitude],
        current_temp: current_temp,
        high_temp: high_temp,
        low_temp: low_temp,
        temperature_unit: current_period['temperatureUnit'],
        conditions: current_period['shortForecast'],
        forecast_short: current_period['shortForecast'],
        forecast_detailed: current_period['detailedForecast'],
        wind_speed: current_period['windSpeed'],
        wind_direction: current_period['windDirection'],
        extended_forecast: extended_forecast,
        timestamp: Time.current
      }
    }
  end

  # Validate zip code format
  #
  # @param zip_code [String] Zip code to validate
  # @return [Boolean] True if valid format
  def valid_zip_code?(zip_code)
    zip_code.present? && zip_code.match?(/^\d{5}(?:-\d{4})?$/)
  end

  # Generate error response
  #
  # @param message [String] Error message
  # @return [Hash] Error response hash
  def error_response(message)
    {
      success: false,
      error: message
    }
  end
end
