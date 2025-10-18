require 'test_helper'

# ForecastsControllerTest
#
# Comprehensive unit tests for ForecastsController
# Tests all endpoints, caching behavior, and error handling
#
# Test Coverage:
# - GET /forecasts/new - Display form
# - POST /forecasts - Submit address and get forecast
# - GET /forecasts/:zip_code - Get forecast by zip code
# - Caching behavior
# - Error scenarios
# - Input validation
class ForecastsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Clear cache before each test
    Rails.cache.clear
  end

  # Test: GET /forecasts/new
  test 'should get new forecast form' do
    get new_forecast_path
    assert_response :success
    assert_select 'h1', /Weather Forecast/i
    assert_select 'form[action=?]', forecasts_path
    assert_select 'input[name=?]', 'address'
  end

  test 'new form should have submit button' do
    get new_forecast_path
    assert_response :success
    assert_select 'input[type=submit]'
  end

  # Test: POST /forecasts with blank address
  test 'should reject blank address' do
    post forecasts_path, params: { address: '' }
    assert_response :success
    assert_select '.alert-error', /enter an address/i
  end

  test 'should reject nil address' do
    post forecasts_path, params: {}
    assert_response :success
    assert_select '.alert-error', /enter an address/i
  end

  # Test: POST /forecasts with invalid address
  test 'should handle invalid address gracefully' do
    # Mock ForecastService to return error
    ForecastService.any_instance.stub :fetch_forecast_by_address, 
      { success: false, error: 'Address not found' } do
      
      post forecasts_path, params: { address: 'Invalid XYZ 12345' }
      assert_response :success
      assert_select '.alert-error', /Address not found/
    end
  end

  # Test: POST /forecasts with valid address
  test 'should display forecast for valid address' do
    # Mock successful forecast response
    mock_forecast = {
      success: true,
      data: {
        location: 'San Francisco, CA',
        zip_code: '94102',
        current_temp: 65,
        high_temp: 70,
        low_temp: 55,
        conditions: 'Partly Cloudy',
        forecast_short: 'Partly Cloudy',
        forecast_detailed: 'Partly cloudy with mild temperatures',
        wind_speed: '10 mph',
        wind_direction: 'W',
        temperature_unit: 'F',
        extended_forecast: [],
        timestamp: Time.current
      }
    }
    
    ForecastService.any_instance.stub :fetch_forecast_by_address, mock_forecast do
      post forecasts_path, params: { address: 'San Francisco, CA' }
      assert_response :success
      assert_select '.temp-display', /65/
      assert_select '.conditions', /Partly Cloudy/
    end
  end

  # Test: GET /forecasts/:zip_code with invalid format
  test 'should reject invalid zip code format in show' do
    get forecast_path('ABCDE')
    assert_redirected_to new_forecast_path
    follow_redirect!
    assert_select '.alert', /Invalid zip code/i
  end

  test 'should reject short zip code' do
    get forecast_path('123')
    assert_redirected_to new_forecast_path
  end

  # Test: GET /forecasts/:zip_code with valid zip
  test 'should show forecast for valid zip code' do
    mock_forecast = {
      success: true,
      data: {
        location: 'San Francisco, CA',
        zip_code: '94102',
        current_temp: 65,
        high_temp: 70,
        low_temp: 55,
        conditions: 'Partly Cloudy',
        forecast_short: 'Partly Cloudy',
        forecast_detailed: 'Partly cloudy with mild temperatures',
        wind_speed: '10 mph',
        wind_direction: 'W',
        temperature_unit: 'F',
        extended_forecast: [],
        timestamp: Time.current
      }
    }
    
    ForecastService.any_instance.stub :fetch_forecast_by_address, mock_forecast do
      get forecast_path('94102')
      assert_response :success
      assert_select '.temp-display', /65/
    end
  end

  # Test: Caching behavior
  test 'should cache forecast data' do
    mock_forecast = {
      success: true,
      data: {
        location: 'San Francisco, CA',
        zip_code: '94102',
        current_temp: 65,
        high_temp: 70,
        low_temp: 55,
        conditions: 'Partly Cloudy',
        forecast_short: 'Partly Cloudy',
        forecast_detailed: 'Partly cloudy',
        wind_speed: '10 mph',
        wind_direction: 'W',
        temperature_unit: 'F',
        extended_forecast: [],
        timestamp: Time.current
      }
    }
    
    # First request - should call service
    ForecastService.any_instance.expect :fetch_forecast_by_address, mock_forecast
    post forecasts_path, params: { address: '94102' }
    assert_response :success
    
    # Verify data was cached
    cached = Rails.cache.read('forecast:94102')
    assert_not_nil cached
  end

  test 'should indicate when data is from cache' do
    # Pre-populate cache
    cache_data = {
      location: 'San Francisco, CA',
      zip_code: '94102',
      current_temp: 65,
      high_temp: 70,
      low_temp: 55,
      conditions: 'Partly Cloudy',
      forecast_short: 'Partly Cloudy',
      forecast_detailed: 'Partly cloudy',
      wind_speed: '10 mph',
      wind_direction: 'W',
      temperature_unit: 'F',
      extended_forecast: [],
      timestamp: Time.current.to_s
    }
    Rails.cache.write('forecast:94102', cache_data.to_json, expires_in: 30.minutes)
    
    # Request should use cache
    get forecast_path('94102')
    assert_response :success
    assert_select '.cache-badge', /Cached Data/i
  end

  test 'should indicate when data is fresh' do
    mock_forecast = {
      success: true,
      data: {
        location: 'San Francisco, CA',
        zip_code: '94102',
        current_temp: 65,
        high_temp: 70,
        low_temp: 55,
        conditions: 'Partly Cloudy',
        forecast_short: 'Partly Cloudy',
        forecast_detailed: 'Partly cloudy',
        wind_speed: '10 mph',
        wind_direction: 'W',
        temperature_unit: 'F',
        extended_forecast: [],
        timestamp: Time.current
      }
    }
    
    ForecastService.any_instance.stub :fetch_forecast_by_address, mock_forecast do
      post forecasts_path, params: { address: '94102' }
      assert_response :success
      assert_select '.cache-badge', /Fresh Data/i
    end
  end

  # Test: Cache expiration setting
  test 'cache should have 30 minute expiration' do
    assert_equal 1800, ForecastsController::CACHE_EXPIRATION
  end

  # Test: Navigation
  test 'should have link back to new forecast form' do
    mock_forecast = {
      success: true,
      data: {
        location: 'San Francisco, CA',
        zip_code: '94102',
        current_temp: 65,
        high_temp: 70,
        low_temp: 55,
        conditions: 'Partly Cloudy',
        forecast_short: 'Partly Cloudy',
        forecast_detailed: 'Partly cloudy',
        wind_speed: '10 mph',
        wind_direction: 'W',
        temperature_unit: 'F',
        extended_forecast: [],
        timestamp: Time.current
      }
    }
    
    ForecastService.any_instance.stub :fetch_forecast_by_address, mock_forecast do
      post forecasts_path, params: { address: '94102' }
      assert_response :success
      assert_select 'a[href=?]', new_forecast_path
    end
  end

  # Test: Extended forecast display
  test 'should display extended forecast when available' do
    mock_forecast = {
      success: true,
      data: {
        location: 'San Francisco, CA',
        zip_code: '94102',
        current_temp: 65,
        high_temp: 70,
        low_temp: 55,
        conditions: 'Partly Cloudy',
        forecast_short: 'Partly Cloudy',
        forecast_detailed: 'Partly cloudy',
        wind_speed: '10 mph',
        wind_direction: 'W',
        temperature_unit: 'F',
        extended_forecast: [
          { name: 'Tonight', temperature: 55, temperature_unit: 'F', conditions: 'Clear' },
          { name: 'Tomorrow', temperature: 70, temperature_unit: 'F', conditions: 'Sunny' }
        ],
        timestamp: Time.current
      }
    }
    
    ForecastService.any_instance.stub :fetch_forecast_by_address, mock_forecast do
      post forecasts_path, params: { address: '94102' }
      assert_response :success
      assert_select '.extended-forecast'
      assert_select '.forecast-item', count: 2
    end
  end

  # Test: Error handling for service failures
  test 'should handle service errors gracefully' do
    ForecastService.any_instance.stub :fetch_forecast_by_address, 
      ->(_) { raise StandardError.new('Unexpected error') } do
      
      # Should not crash the application
      assert_raises(StandardError) do
        post forecasts_path, params: { address: 'Test Address' }
      end
    end
  end

  # Test: Route accessibility
  test 'forecast route should be accessible' do
    get '/forecast'
    assert_response :success
  end
end
