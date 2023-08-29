/// The collection of weather information for a location.
enum DataSet {
  /// The current weather for the requested location.
  currentWeather,

  /// The daily forecast for the requested location.
  forecastDaily,

  /// The hourly forecast for the requested location.
  forecastHourly,

  /// The next hour forecast for the requested location.
  forecastNextHour,

  /// Weather alerts for the requested location.
  weatherAlerts;

  static DataSet fromString(String name) => switch (name) {
    'currentWeather' => DataSet.currentWeather,
    'forecastDaily' => DataSet.forecastDaily,
    'forecastHourly' => DataSet.forecastHourly,
    'forecastNextHour' => DataSet.forecastNextHour,
    'weatherAlerts' => DataSet.weatherAlerts,
    _ => throw ArgumentError.value(name, 'name', 'Invalid data set name.'),
  };
}
