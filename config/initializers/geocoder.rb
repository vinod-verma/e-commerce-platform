# Geocoder Configuration
#
# Configuration for the Geocoder gem used to convert addresses to coordinates
#
# Documentation: https://github.com/alexreisner/geocoder
#
# Scalability Considerations:
# - Uses timeouts to prevent hanging requests
# - Implements caching to reduce API calls
# - Can be configured with different lookup services (Google, Nominatim, etc.)

Geocoder.configure(
  # Geocoding service timeout (seconds)
  timeout: 5,
  
  # Lookup service - using Nominatim (OpenStreetMap) as it's free and doesn't require API key
  # For production, consider Google Maps API or other premium services
  lookup: :nominatim,
  
  # Use HTTPS for secure communication
  use_https: true,
  
  # Cache geocoding results to reduce API calls
  # Uses Rails.cache (Redis in production)
  cache: Rails.cache,
  cache_prefix: 'geocoder:',
  
  # Units: :mi (miles) or :km (kilometers)
  units: :mi,
  
  # Nominatim specific configuration
  nominatim: {
    # Required by Nominatim terms of service
    email: 'weather-app@example.com'
  }
)
