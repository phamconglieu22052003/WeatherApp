import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_service.dart';
import 'day_detail_screen.dart';

class ForecastScreen extends StatefulWidget {
  final String city;

  const ForecastScreen({required this.city});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final WeatherService _weatherService = WeatherService();
  List<dynamic>? _forecast;

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    try {
      final forecastData = await _weatherService.fetch7DayForecast(widget.city);
      setState(() {
        _forecast = forecastData['forecast']['forecastday'];
      });
    } catch (e) {
      print(e);
    }
  }

  List<Color> getGradientByCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return [Color(0xFFFFE57F), Color(0xFFFFD54F), Color(0xFFFFCA28)];
      case 'partly cloudy':
        return [Color(0xFF6D83F2), Color(0xFF8A9EF7), Color(0xFFA3B2FC)];
      case 'cloudy':
      case 'overcast':
        return [Color(0xFF4C5C68), Color(0xFF66778D), Color(0xFF9AA5B1)];
      case 'light rain':
      case 'moderate rain':
        return [Color(0xFF37517E), Color(0xFF4A6785), Color(0xFF6A89A6)];
      case 'heavy rain':
        return [Color(0xFF232526), Color(0xFF414345), Color(0xFF5C5F63)];
      case 'snow':
        return [Color(0xFFB5D3E7), Color(0xFFD0E6F5), Color(0xFFF0F8FF)];
      default:
        return [
          Color(0xFF1A2344),
          Color.fromARGB(255, 125, 32, 142),
          Colors.purple,
          Color.fromARGB(255, 151, 44, 170),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColors = _forecast != null && _forecast!.isNotEmpty
        ? getGradientByCondition(_forecast![0]['day']['condition']['text'])
        : [
      Color(0xFF1A2344),
      Color.fromARGB(255, 125, 32, 142),
      Colors.purple,
      Color.fromARGB(255, 151, 44, 170),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white), // màu icon (nút back)
        foregroundColor: Colors.white, // màu chữ mặc định (nếu có)
        title: Text(
          'Thời tiết 7 ngày tới',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white, // đảm bảo chữ cũng trắng
          ),
        ),
      ),
      body: _forecast == null
          ? Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: backgroundColors,
          ),
        ),
        child: ListView.builder(
          itemCount: _forecast!.length,
          itemBuilder: (context, index) {
            final day = _forecast![index];
            String iconUrl = 'http:${day['day']['condition']['icon']}';
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DayDetailScreen(
                              date: day['date'],
                              hourlyData: day['hour'],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Image.network(iconUrl),
                        title: Text(
                          '${day['date']}',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        subtitle: Text(
                          '${day['day']['condition']['text']}',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day['day']['avgtemp_c'].round()}°C',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Cao nhất: ${day['day']['maxtemp_c'].round()}°C\nThấp nhất: ${day['day']['mintemp_c'].round()}°C',
                              style: GoogleFonts.lato(
                                fontSize: 10,
                                color: Colors.black54,

                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
