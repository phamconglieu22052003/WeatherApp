import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DayDetailScreen extends StatelessWidget {
  final String date;
  final List<dynamic> hourlyData;

  const DayDetailScreen({required this.date, required this.hourlyData, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A2344),
        foregroundColor: Colors.white, // thêm dòng này
        title: Text('Chi tiết $date'),
      ),
      body: ListView.builder(
        itemCount: hourlyData.length,
        itemBuilder: (context, index) {
          final hour = hourlyData[index];
          final time = hour['time'].split(' ')[1];
          final temp = hour['temp_c'];
          final condition = hour['condition']['text'];
          return ListTile(
            leading: Image.network('http:${hour['condition']['icon']}'),
            title: Text('$time - $temp°C', style: GoogleFonts.lato()),
            subtitle: Text(condition),
          );
        },
      ),
    );
  }
}
