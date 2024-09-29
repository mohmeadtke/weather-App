import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

// Create a WeatherData class to hold temperature and wind speed
class WeatherData {
  final double temperature;
  final double windSpeed;

  WeatherData({required this.temperature, required this.windSpeed});
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<WeatherData> weatherData; // Update to WeatherData

  @override
  void initState() {
    super.initState();
    weatherData = WitherApi().fetchTemperature(); // Fetch WeatherData
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: FutureBuilder<WeatherData>(
          future: weatherData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Temperature: ${data.temperature}°C'),
                  Text('Wind Speed: ${data.windSpeed} km/h'),
                ],
              );
            } else {
              return const Text('No data available');
            }
          },
        ),
      ),
    );
  }
}

class WitherApi {
  Future<WeatherData> fetchTemperature() async { // Change return type to Future<WeatherData>
    const url =
        'http://api.weatherapi.com/v1/current.json?key=c14e6834322b4e8f9d372148242909&q=iraq&aqi=yes';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final temp = data['current']['temp_c']; // Access the temperature in Celsius
      final wind = data['current']['wind_kph']; // Access the wind speed in km/h
      return WeatherData(
        temperature: temp.toDouble(),
        windSpeed: wind.toDouble(),
      );
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
