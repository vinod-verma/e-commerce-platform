# Code Samples - Weather Forecast Feature

This document provides code samples demonstrating key aspects of the implementation.

## Service Object Example

### ForecastService - Main Entry Point

```ruby
class ForecastService
  # Main method to fetch forecast by address
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
    error_response("Failed to fetch forecast: #{e.message}")
  end
end
```

### Geocoding Implementation

```ruby
# Private method in ForecastService
def geocode_address(address)
  results = Geocoder.search(address)

  if results.empty?
    return error_response('Address not found.')
  end

  result = results.first
  
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
  error_response('Failed to geocode address.')
end
```

## Controller Example

### Caching Implementation

```ruby
class ForecastsController < ApplicationController
  CACHE_EXPIRATION = 30.minutes.to_i

  private

  def fetch_with_cache(address)
    # Initialize service
    service = ForecastService.new

    # Check if address is already a zip code
    if address.match?(/^\d{5}(?:-\d{4})?$/)
      # Try cache first
      cached_data = read_from_cache(address)
      if cached_data
        Rails.logger.info("Cache hit for zip code: #{address}")
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
end
```

### Cache Read/Write

```ruby
def read_from_cache(zip_code)
  return nil if zip_code.blank?

  cache_key = "forecast:#{zip_code}"
  cached_json = Rails.cache.read(cache_key)
  
  if cached_json
    data = JSON.parse(cached_json, symbolize_names: true)
    data[:timestamp] = Time.parse(data[:timestamp])
    data
  else
    nil
  end
rescue StandardError => e
  Rails.logger.error("Cache read error: #{e.message}")
  nil
end

def write_to_cache(zip_code, data)
  return if zip_code.blank?

  cache_key = "forecast:#{zip_code}"
  data_json = data.to_json
  
  Rails.cache.write(cache_key, data_json, expires_in: CACHE_EXPIRATION)
  Rails.logger.info("Cached forecast for zip: #{zip_code}")
rescue StandardError => e
  Rails.logger.error("Cache write error: #{e.message}")
end
```

## Test Examples

### Service Test

```ruby
class ForecastServiceTest < ActiveSupport::TestCase
  def setup
    @service = ForecastService.new
  end

  test 'returns error for blank address' do
    result = @service.fetch_forecast_by_address('')
    
    assert_equal false, result[:success]
    assert_equal 'Address cannot be blank', result[:error]
  end

  test 'handles geocoding errors gracefully' do
    Geocoder.stub :search, ->(_) { raise Geocoder::Error } do
      result = @service.fetch_forecast_by_address('123 Test St')
      
      assert_equal false, result[:success]
      assert_match(/geocode/, result[:error].downcase)
    end
  end
end
```

### Controller Test with Caching

```ruby
class ForecastsControllerTest < ActionDispatch::IntegrationTest
  def setup
    Rails.cache.clear
  end

  test 'should cache forecast data' do
    mock_forecast = {
      success: true,
      data: {
        location: 'San Francisco, CA',
        zip_code: '94102',
        current_temp: 65,
        # ... more data
      }
    }
    
    # First request - should call service
    ForecastService.any_instance.stub :fetch_forecast_by_address, 
      mock_forecast do
      post forecasts_path, params: { address: '94102' }
      assert_response :success
    end
    
    # Verify data was cached
    cached = Rails.cache.read('forecast:94102')
    assert_not_nil cached
  end
end
```

## View Examples

### Form View (new.html.erb)

```erb
<%= form_with url: forecasts_path, method: :post, local: true do |f| %>
  <div class="form-group">
    <label for="address">Enter Address or Zip Code:</label>
    <%= f.text_field :address, 
        placeholder: "e.g., 123 Main St, San Francisco, CA or 94102",
        required: true,
        autofocus: true %>
  </div>
  
  <%= f.submit "Get Forecast", class: "btn" %>
<% end %>
```

### Forecast Display (show.html.erb)

```erb
<!-- Cache Indicator -->
<div class="cache-badge <%= @from_cache ? 'from-cache' : 'fresh-data' %>">
  <%= @from_cache ? '📦 Cached Data' : '✨ Fresh Data' %>
</div>

<!-- Current Weather -->
<div class="current-weather">
  <div class="conditions"><%= @forecast[:conditions] %></div>
  <div class="temp-display">
    <%= @forecast[:current_temp] %>°<%= @forecast[:temperature_unit] %>
  </div>
  <div class="temp-range">
    High: <%= @forecast[:high_temp] %>° | Low: <%= @forecast[:low_temp] %>°
  </div>
</div>

<!-- Extended Forecast -->
<% @forecast[:extended_forecast].each do |period| %>
  <div class="forecast-item">
    <div class="forecast-item-name"><%= period[:name] %></div>
    <div class="forecast-item-temp">
      <%= period[:temperature] %>°<%= period[:temperature_unit] %>
    </div>
    <div class="forecast-item-conditions"><%= period[:conditions] %></div>
  </div>
<% end %>
```

## Configuration Examples

### Geocoder Configuration

```ruby
# config/initializers/geocoder.rb
Geocoder.configure(
  timeout: 5,
  lookup: :nominatim,
  use_https: true,
  cache: Rails.cache,
  cache_prefix: 'geocoder:',
  units: :mi,
  nominatim: {
    email: 'weather-app@example.com'
  }
)
```

### Routes Configuration

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :forecasts, only: [:new, :create, :show]
  get '/forecast', to: 'forecasts#new'
end
```

## Usage Examples

### Console Usage

```ruby
# In Rails console
service = ForecastService.new

# Fetch by address
result = service.fetch_forecast_by_address("San Francisco, CA")

# Fetch by zip code
result = service.fetch_forecast_by_zip("94102")

# Check result
if result[:success]
  puts "Current temp: #{result[:data][:current_temp]}°F"
  puts "Conditions: #{result[:data][:conditions]}"
else
  puts "Error: #{result[:error]}"
end
```

### Background Job Usage

```ruby
# Example of using service in background job
class WeatherUpdateJob < ApplicationJob
  queue_as :default

  def perform(zip_code)
    service = ForecastService.new
    result = service.fetch_forecast_by_zip(zip_code)
    
    if result[:success]
      # Store in database or send notification
      WeatherNotification.send(result[:data])
    else
      Rails.logger.error("Failed to update weather: #{result[:error]}")
    end
  end
end

# Schedule job
WeatherUpdateJob.perform_later("94102")
```

### API-Style Usage

```ruby
# If building API endpoints
class Api::V1::ForecastsController < Api::BaseController
  def show
    service = ForecastService.new
    result = service.fetch_forecast_by_zip(params[:zip_code])
    
    if result[:success]
      render json: result[:data], status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end
end
```

## Error Handling Examples

### Service Error Response

```ruby
def error_response(message)
  {
    success: false,
    error: message
  }
end
```

### Controller Error Handling

```ruby
def create
  address = params[:address]

  if address.blank?
    flash.now[:error] = 'Please enter an address or zip code'
    render :new
    return
  end

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
```

## Logging Examples

```ruby
# Service logging
Rails.logger.info("Fetching forecast for: #{address}")
Rails.logger.error("Geocoding error: #{e.message}")

# Controller logging
Rails.logger.info("Cache hit for zip code: #{zip_code}")
Rails.logger.info("Cached forecast for zip code: #{zip_code} (expires in 30 min)")
```

## Response Structure

### Successful Response

```ruby
{
  success: true,
  data: {
    location: "San Francisco, CA 94102",
    zip_code: "94102",
    latitude: 37.7749,
    longitude: -122.4194,
    current_temp: 65,
    high_temp: 70,
    low_temp: 55,
    temperature_unit: "F",
    conditions: "Partly Cloudy",
    forecast_short: "Partly Cloudy",
    forecast_detailed: "Partly cloudy with mild temperatures...",
    wind_speed: "10 mph",
    wind_direction: "W",
    extended_forecast: [
      {
        name: "Tonight",
        temperature: 55,
        temperature_unit: "F",
        conditions: "Clear",
        detailed_forecast: "Clear skies...",
        wind_speed: "5 mph",
        wind_direction: "NW"
      },
      # ... 6 more periods
    ],
    timestamp: "2025-10-18T17:30:00Z"
  },
  from_cache: false  # Only in controller response
}
```

### Error Response

```ruby
{
  success: false,
  error: "Address not found. Please provide a valid US address."
}
```

## Best Practices Demonstrated

### 1. Single Responsibility

Each method does one thing:
- `fetch_forecast_by_address`: Orchestrates the process
- `geocode_address`: Only geocodes
- `fetch_weather_data`: Only fetches weather
- `parse_forecast_response`: Only parses response

### 2. DRY (Don't Repeat Yourself)

```ruby
# Error response method reused throughout
def error_response(message)
  { success: false, error: message }
end
```

### 3. Defensive Programming

```ruby
# Always check for nil/blank
return error_response('Address cannot be blank') if address.blank?

# Handle all exceptions
rescue StandardError => e
  Rails.logger.error("Error: #{e.message}")
  error_response("Failed: #{e.message}")
end
```

### 4. Structured Data

```ruby
# Consistent hash structure
{
  success: Boolean,
  data: Hash,
  error: String
}
```

## Summary

These code samples demonstrate:
- ✅ Clean, readable code
- ✅ Proper error handling
- ✅ Comprehensive logging
- ✅ Testable design
- ✅ Best practices
- ✅ Enterprise patterns
- ✅ Reusable components

All code follows Ruby and Rails conventions and is production-ready.
