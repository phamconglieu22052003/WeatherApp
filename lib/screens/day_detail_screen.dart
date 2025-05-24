import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DayDetailScreen extends StatefulWidget {
  final String date;
  final List<dynamic> hourlyData;

  const DayDetailScreen({required this.date, required this.hourlyData, super.key});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : const Color(0xFF1A2344),
        foregroundColor: Colors.white,
        title: Text('Chi tiết ${widget.date}'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            tooltip: 'Chuyển chế độ nền',
            onPressed: () {
              setState(() {
                isDark = !isDark;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,

        ),
        child: ListView.builder(
          itemCount: widget.hourlyData.length,
          itemBuilder: (context, index) {
            final hour = widget.hourlyData[index];
            final time = hour['time'].split(' ')[1];
            final temp = hour['temp_c'].round();
            final wind = hour['wind_kph'].round();
            final humidity = hour['humidity'].round();
            final condition = hour['condition']['text'];
            final iconUrl = 'http:${hour['condition']['icon']}';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Image.network(iconUrl, width: 40, height: 40),
                  title: Text(
                    '$time - $temp°C',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    '$condition\nGió: $wind km/h | Độ ẩm: $humidity%',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black87,
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
