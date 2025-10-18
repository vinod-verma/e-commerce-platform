# frozen_string_literal: true

# ForecastsController
#
# Controller responsible for handling weather forecast HTTP requests.
# Implements the Controller pattern in the MVC architecture.
#
# Design Patterns:
# - MVC Pattern: Controller layer handling user input and response
# - Facade Pattern: Provides simple interface to complex service layer
#
# Responsibilities:
# - Accept user input (addresses)
# - Delegate business logic to ForecastService
# - Implement caching strategy (30-minute TTL by zip code)
# - Render appropriate responses
# - Handle errors gracefully
#
# Caching Strategy:
# - Cache key: "forecast:#{zip_code}"
# - TTL: 30 minutes (1800 seconds)
# - Indicates cache hits with :from_cache flag
#
# Scalability Considerations:
# - Uses Redis for distributed caching
# - Cache by zip code for efficient reuse
# - Reduces external API calls significantly
# - Can handle high traffic with cached responses
#
# Endpoints:
# - GET /forecasts/new - Display form for address input
# - POST /forecasts - Fetch and display forecast
class ForecastsController < ApplicationController
  # Skip CSRF protection for API-style POST requests if needed
  # skip_before_action :verify_authenticity_token, only: [:create]
  
  # Cache expiration time in seconds (30 minutes)
  CACHE_EXPIRATION = 30.minutes.to_i

  # Display form for address input
  #
  # GET /forecasts/new
  def new
    # Render the form view
  end

  # Fetch and display forecast for submitted address
  #
  # POST /forecasts
  #
  # Parameters:
  #   address: String - Full address or zip code
  #
  # Response:
  #   Renders forecast view with data or error message
  def create
    address = params[:address]

    # Validate input
    if address.blank?
      flash.now[:error] = 'Please enter an address or zip code'
      render :new
      return
    end

    # Try to get forecast (with caching)
    result = fetch_with_cache(address)

    if result[:success]
      @forecast = result[:data]
      @from_cache = result[:from_cache]
      render :show
    else
      flash.now[:error] = result[:error]
      render :new
    end
  end

  # Display forecast (same as create but for GET requests)
  #
  # GET /forecasts/:zip_code
  #
  # Parameters:
  #   zip_code: String - 5-digit zip code
  def show
    zip_code = params[:id]

    # Validate zip code format
    unless zip_code.match?(/^\d{5}(?:-\d{4})?$/)
      flash[:error] = 'Invalid zip code format'
      redirect_to new_forecast_path
      return
    end

    result = fetch_with_cache(zip_code)

    if result[:success]
      @forecast = result[:data]
      @from_cache = result[:from_cache]
    else
      flash[:error] = result[:error]
      redirect_to new_forecast_path
    end
  end

  private

  # Fetch forecast with caching layer
  #
  # Implements caching strategy:
  # 1. Check if data exists in cache (by zip code)
  # 2. If yes, return cached data with :from_cache flag
  # 3. If no, fetch from service and cache result
  #
  # @param address [String] Address or zip code
  # @return [Hash] Result with :success, :data, :from_cache, and optional :error
  def fetch_with_cache(address)
    # Initialize service
    service = ForecastService.new

    # First, get forecast to determine zip code
    result = if address.match?(/^\d{5}(?:-\d{4})?$/)
               # Address is already a zip code
               { zip_code: address, use_cache: true }
             else
               # Need to geocode first to get zip code
               { zip_code: nil, use_cache: false }
             end

    # If we have a zip code, try cache first
    if result[:use_cache]
      cached_data = read_from_cache(result[:zip_code])
      if cached_data
        Rails.logger.info("Cache hit for zip code: #{result[:zip_code]}")
        return {
          success: true,
          data: cached_data,
          from_cache: true
        }
      end
    end

    # Fetch from service
    Rails.logger.info("Fetching fresh data for: #{address}")
    forecast_result = service.fetch_forecast_by_address(address)

    # If successful, cache the result
    if forecast_result[:success]
      zip_code = forecast_result[:data][:zip_code]
      write_to_cache(zip_code, forecast_result[:data])
      forecast_result[:from_cache] = false
    end

    forecast_result
  end

  # Read forecast data from cache
  #
  # @param zip_code [String] Zip code as cache key
  # @return [Hash, nil] Cached forecast data or nil if not found
  def read_from_cache(zip_code)
    return nil if zip_code.blank? || zip_code == 'Unknown'

    cache_key = "forecast:#{zip_code}"
    cached_json = Rails.cache.read(cache_key)
    
    if cached_json
      # Parse JSON and convert timestamp back to Time object
      data = JSON.parse(cached_json, symbolize_names: true)
      data[:timestamp] = Time.parse(data[:timestamp]) if data[:timestamp]
      data
    else
      nil
    end
  rescue StandardError => e
    Rails.logger.error("Cache read error: #{e.message}")
    nil
  end

  # Write forecast data to cache
  #
  # @param zip_code [String] Zip code as cache key
  # @param data [Hash] Forecast data to cache
  def write_to_cache(zip_code, data)
    return if zip_code.blank? || zip_code == 'Unknown'

    cache_key = "forecast:#{zip_code}"
    
    # Convert to JSON for storage
    data_json = data.to_json
    
    Rails.cache.write(cache_key, data_json, expires_in: CACHE_EXPIRATION)
    Rails.logger.info("Cached forecast for zip code: #{zip_code} (expires in #{CACHE_EXPIRATION} seconds)")
  rescue StandardError => e
    Rails.logger.error("Cache write error: #{e.message}")
    # Don't fail the request if caching fails
  end
end
