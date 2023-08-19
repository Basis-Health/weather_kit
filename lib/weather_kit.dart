library weather_kit;

export 'src/models/data_set.dart';

import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:weather_kit/src/constants/base_url.dart';
import 'package:weather_kit/src/models/current_weather_data.dart';
import 'package:weather_kit/src/models/data_set.dart';

class WeatherKit {
  String generateJWT({
    required final String bundleId,
    required final String teamId,
    required final String keyId,
    required final String pem,
    required final Duration expiresIn,
  }) {
    final jwt = JWT(
      {
        'sub': bundleId,
      },
      issuer: teamId,
      header: {
        "typ": "JWT",
        'id': "$teamId.$bundleId",
        'alg': 'ES256',
        'kid': keyId,
      },
    );
    final token = jwt.sign(
      ECPrivateKey(
        pem,
      ),
      algorithm: JWTAlgorithm.ES256,
      expiresIn: expiresIn,
    );
    return token;
  }

  /// [country] should be the ISO Alpha-2 country code.
  Future<List<dynamic>> obtainAvailability({
    required final String jwt,
    required final double latitude,
    required final double longitude,
    required final String country,
  }) async {
    assert(latitude >= -90 || latitude <= 90);
    assert(latitude >= -180 || latitude <= 180);
    final response = await http.get(
      Uri.parse("$baseUrl/availability/$latitude/$longitude?country=$country"),
      headers: {HttpHeaders.authorizationHeader: jwt},
    );
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw Exception('Failed to obtain availability. Status code: ${response.statusCode}. Response body: ${response.body}');
    }
    final decode = json.decode(response.body);
    if (decode is! List) {
      throw FormatException('Response body is not a list. Response body: ${response.body}');
    }

    return decode;
  }

  /// Obtain weather data for the specified location.
  Future<CurrentWeatherData> obtainWeatherData({
    required final String jwt,
    required final String language,
    required final double latitude,
    required final double longitude,
    required final DataSet dataSets,
    required final String timezone,
    final String? countryCode,
    final DateTime? currentAsOf,
    final DateTime? dailyEnd,
    final DateTime? dailyStart,
    final DateTime? hourlyEnd,
    final DateTime? hourlyStart,
  }) async {
    assert(latitude >= -90.0 || latitude <= 90.0);
    assert(latitude >= -180.0 || latitude <= 180.0);
    String url = '$baseUrl/weather/$language/$latitude/$longitude?dataSets=${dataSets.name}&timezone=$timezone';

    if (countryCode != null) {
      url = '$url&countryCode=$countryCode';
    }
    if (currentAsOf != null) {
      url = '$url&currentAsOf=${currentAsOf.toUtc().toIso8601String()}';
    }
    if (dailyEnd != null) {
      url = '$url&dailyEnd=${dailyEnd.toUtc().toIso8601String()}';
    }
    if (dailyStart != null) {
      url = '$url&dailyStart=${dailyStart.toUtc().toIso8601String()}';
    }
    if (hourlyEnd != null) {
      url = '$url&hourlyEnd=${hourlyEnd.toUtc().toIso8601String()}';
    }
    if (hourlyStart != null) {
      url = '$url&hourlyStart=${hourlyStart.toUtc().toIso8601String()}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: jwt},
    );
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw Exception('Failed to obtain availability. Status code: ${response.statusCode}. Response body: ${response.body}');
    }
    try {
      return CurrentWeatherData.fromJson(response.body);
    } catch (e) {
      throw FormatException('Failed to parse response body: $e. Response body: ${response.body}');
    }
  }
}
