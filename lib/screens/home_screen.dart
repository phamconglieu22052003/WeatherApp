import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_qpp/services/weather_service.dart';
import 'forecast_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  String _city = "London";
  Map<String, dynamic>? _currentWeather;
  bool _isCelsius = true;
  double _getMaxTempOfDay() {
    final List hours = _currentWeather!['forecast']['forecastday'][0]['hour'];
    return hours.map((h) => h['temp_c'] as double).reduce((a, b) => a > b ? a : b);
  }

  double _getMinTempOfDay() {
    final List hours = _currentWeather!['forecast']['forecastday'][0]['hour'];
    return hours.map((h) => h['temp_c'] as double).reduce((a, b) => a < b ? a : b);
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  String _formatTemp(dynamic tempC) {
    if (tempC == null) return '--';
    final tempF = (tempC * 9 / 5 + 32).round();
    final roundedC = tempC.round();

    return _isCelsius ? '$roundedC°C' : '$tempF°F';
  }

  Future<void> _fetchWeather() async {
    try {
      final weatherData = await _weatherService.fetchCurrentWeather(_city);
      setState(() {
        _currentWeather = weatherData;
      });
    } catch (e) {
      print(e);
    }
  }

  void _showCitySelectionDialog() {
    String _tempCity = ""; // thêm biến tạm
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Center(
            child: Text(
              "Nhập tên thành phố",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
          ),
          content: TypeAheadField(
            suggestionsCallback: (pattern) async {
              return await _weatherService.fetchCitySuggestions(pattern);
            },
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  labelText: "Thành phố",
                  labelStyle: TextStyle(fontSize: 14),
                ),
              );
            },
            itemBuilder: (context, suggestion) {
              return ListTile(title: Text(suggestion['name']));
            },
            onSelected: (city) {
              _tempCity = city['name']; // chỉ lưu tạm, không gọi API
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (_tempCity.isNotEmpty) {
                  setState(() {
                    _city = _tempCity;
                  });
                  _fetchWeather();
                }
              },
              child: Text("Xác nhận"),
            ),

          ],
        );
      },
    );
  }

  void _getWeatherByLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text("Định vị đang tắt"),
              content: Text("Vui lòng bật GPS để lấy thời tiết theo vị trí."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
      );
      return;
    }
    try {
      final position = await _weatherService.getCurrentLocation();
      final weatherData = await _weatherService.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _currentWeather = weatherData;
        _city = weatherData['location']['name'];
      });
    } catch (e) {
      print('Lỗi GPS: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể lấy thời tiết từ GPS')));
    }
  }

  void _showHourlyDetails(String type, List<dynamic> hourlyData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chi tiết $type'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: hourlyData.length,
              itemBuilder: (context, index) {
                final hour = hourlyData[index];
                final time = hour['time'].split(' ')[1];
                String value;

                switch (type.toLowerCase()) {
                  case 'độ ẩm':
                    value = '${hour['humidity']}%';
                    break;
                  case 'gió':
                    value = '${hour['wind_kph'].round()} km/h';
                    break;
                  default:
                    value = '${hour['temp_c'].round()}°C';
                }

                return ListTile(
                  title: Text('$time: $value'),
                  subtitle: Text(hour['condition']['text']),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          _city,
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: _showCitySelectionDialog,
          ),
          IconButton(
            icon: Icon(Icons.my_location, color: Colors.white),
            tooltip: 'Lấy thời tiết theo vị trí hiện tại',
            onPressed: _getWeatherByLocation,
          ),
          IconButton(
            icon: Icon(
              _isCelsius ? Icons.device_thermostat : Icons.ac_unit,
              color: Colors.white,
            ),
            tooltip: _isCelsius ? 'Đổi sang °F' : 'Đổi sang °C',
            onPressed: () {
              setState(() {
                _isCelsius = !_isCelsius;
              });
            },
          ),
        ],
      ),

      extendBodyBehindAppBar: true,
      body:
          _currentWeather == null
              ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A2344),
                      Color.fromARGB(255, 125, 32, 142),
                      Colors.purple,
                      Color.fromARGB(255, 151, 44, 170),
                    ],
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
              : Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A2344),
                      Color.fromARGB(255, 120, 42, 142),
                      Colors.indigoAccent,
                      Color.fromARGB(255, 151, 44, 100),
                    ],
                  ),
                ),
                child: ListView(
                  children: [
                    SizedBox(height: 25),
                    Center(
                      child: Column(
                        children: [
                          Image.network(
                            'http:${_currentWeather!['current']['condition']['icon']}',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            _formatTemp(
                              _currentWeather!['current']['temp_c'].round(),
                            ),
                            style: GoogleFonts.lato(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _currentWeather!['current']['condition']['text'],
                            style: GoogleFonts.lato(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Cao nhất: ${_formatTemp(_getMaxTempOfDay())}',
                                style: GoogleFonts.lato(
                                  fontSize: 22,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Thấp nhất: ${_formatTemp(_getMinTempOfDay())}',
                                style: GoogleFonts.lato(
                                  fontSize: 22,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 45),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildWeatherDetail(
                          context,
                          'Bình minh',
                          Icons.wb_sunny,
                          _currentWeather!['forecast']['forecastday'][0]['astro']['sunrise'],
                          'Bình minh',
                          _currentWeather!['forecast']['forecastday'][0]['hour'],
                        ),
                        _buildWeatherDetail(
                          context,
                          'Hoàng hôn',
                          Icons.brightness_3,
                          _currentWeather!['forecast']['forecastday'][0]['astro']['sunset'],
                          'Hoàng hôn',
                          _currentWeather!['forecast']['forecastday'][0]['hour'],
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildWeatherDetail(
                          context,
                          'Độ ẩm',
                          Icons.opacity,
                          '${_currentWeather!['current']['humidity']}%',
                          'Độ ẩm',
                          _currentWeather!['forecast']['forecastday'][0]['hour'],
                        ),
                        _buildWeatherDetail(
                          context,
                          'Gió',
                          Icons.wind_power,
                          '${_currentWeather!['current']['wind_kph'].round()} km/h',
                          'Gió',
                          _currentWeather!['forecast']['forecastday'][0]['hour'],
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForecastScreen(city: _city),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A2344),
                        ),
                        child: Text(
                          "Dự báo 7 ngày tới",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context,
    String label,
    IconData icon,
    dynamic value,
    String detailTitle,
    List<dynamic> hourlyData,
  ) {
    return GestureDetector(
      onTap: () => _showHourlyDetails(label, hourlyData),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: EdgeInsets.all(5),
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.circular(10),
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  Color(0xFF1A2344).withOpacity(0.5),
                  Color(0xFF1A2344).withOpacity(0.2),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  value.toString(),
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
