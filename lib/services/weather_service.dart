import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  final String apiKey =
      "e893bdcd91254d57939190711250406"; // <--- Thay bằng key riêng nếu cần
  final String forecastBaseUrl = 'http://api.weatherapi.com/v1/forecast.json';
  final String searchBaseUrl = 'http://api.weatherapi.com/v1/search.json';
  final String currentWeatherBaseUrl =
      'http://api.weatherapi.com/v1/current.json';

  /// Lấy vị trí hiện tại bằng GPS
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Dịch vụ định vị đang tắt");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Bạn đã từ chối quyền truy cập vị trí");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Bạn đã từ chối quyền truy cập vị trí vĩnh viễn");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Gọi API thời tiết theo vị trí GPS
  Future<Map<String, dynamic>> fetchWeatherByLocation(
    double lat,
    double lon,
  ) async {
    final url =
        'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$lat,$lon&days=1&aqi=no&alerts=no';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Lỗi khi lấy dự báo thời tiết từ vị trí');
    }
  }

  /// Hàm sẵn có trước đó vẫn dùng được:
  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    final url = '$forecastBaseUrl?key=$apiKey&q=$city&days=1&aqi=no&alerts=no';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Lỗi khi tải thời tiết theo tên thành phố");
    }
  }

  Future<List<dynamic>> fetchCitySuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    final url = '$searchBaseUrl?key=$apiKey&q=$query';
    print('Gọi URL tìm kiếm: $url'); // Log ra để xem
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Lỗi khi gọi API: ${response.body}');
      throw Exception("Lỗi khi tìm kiếm thành phố");
    }
  }

  Future<Map<String, dynamic>> fetch7DayForecast(String city) async {
    final url = '$forecastBaseUrl?key=$apiKey&q=$city&days=7&aqi=no&alerts=no';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Lỗi khi tải dự báo 7 ngày");
    }
  }
}
