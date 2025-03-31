import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HourlyForecastSection extends StatefulWidget {
  final String cityName;

  const HourlyForecastSection({super.key, required this.cityName});

  @override
  State<HourlyForecastSection> createState() => _HourlyForecastSectionState();
}

class _HourlyForecastSectionState extends State<HourlyForecastSection> {
  List<dynamic> hourlyData = [];
  final ScrollController _hourlyController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchHourlyForecast();
  }

  @override
  void didUpdateWidget(covariant HourlyForecastSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityName != widget.cityName) {
      _hourlyController.jumpTo(0);
      fetchHourlyForecast();
    }
  }

  Future<void> fetchHourlyForecast() async {
    if (widget.cityName.isEmpty) return;

    final apiKey = "8e66025cad9a10b209e91404f24cafd6";
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=${widget.cityName}&appid=$apiKey&units=metric&lang=en");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['list'].take(8).toList();
        setState(() {
          hourlyData = list;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Hourly forecast error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return const Center(child: Text("No hourly data available", style: TextStyle(color: Colors.white70)));
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        controller: _hourlyController,
        scrollDirection: Axis.horizontal,
        itemCount: hourlyData.length,
        itemBuilder: (context, index) {
          final item = hourlyData[index];
          final time = DateFormat.Hm().format(DateTime.parse(item['dt_txt']));
          final icon = item['weather'][0]['icon'];
          final temp = item['main']['temp'];

          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(time, style: const TextStyle(color: Colors.white)),
                Image.network(
                  "https://openweathermap.org/img/wn/$icon@2x.png",
                  width: 40,
                  height: 40,
                ),
                Text("${temp.toStringAsFixed(0)}°", style: const TextStyle(color: Colors.white)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DailyForecastSection extends StatefulWidget {
  final String cityName;

  const DailyForecastSection({super.key, required this.cityName});

  @override
  State<DailyForecastSection> createState() => _DailyForecastSectionState();
}

class _DailyForecastSectionState extends State<DailyForecastSection> {
  List<Map<String, dynamic>> dailyForecast = [];

  @override
  void initState() {
    super.initState();
    fetchDailyForecast();
  }

  @override
  void didUpdateWidget(covariant DailyForecastSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityName != widget.cityName) {
      fetchDailyForecast();
    }
  }

  Future<void> fetchDailyForecast() async {
    if (widget.cityName.isEmpty) return;

    final apiKey = "8e66025cad9a10b209e91404f24cafd6";
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=${widget.cityName}&appid=$apiKey&units=metric&lang=en");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastList = data['list'];

        final Map<String, Map<String, dynamic>> dailyMap = {};

        for (var item in forecastList) {
          final dateTime = DateTime.parse(item['dt_txt']);
          final date = DateFormat('yyyy-MM-dd').format(dateTime);

          if (!dailyMap.containsKey(date) && dateTime.hour == 12) {
            dailyMap[date] = {
              'day': DateFormat.E().format(dateTime),
              'temp': item['main']['temp'],
              'icon': item['weather'][0]['icon'],
            };
          }
        }

        final list = dailyMap.values.take(5).toList();

        setState(() {
          dailyForecast = list;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Daily forecast error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dailyForecast.isEmpty) {
      return const Center(child: Text("No daily forecast available", style: TextStyle(color: Colors.white70)));
    }

    return Column(
      children: dailyForecast.map((item) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(50),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                  child: Text(item['day'],
                      style: const TextStyle(fontSize: 16, color: Colors.white))),
              Image.network(
                "https://openweathermap.org/img/wn/${item['icon']}@2x.png",
                width: 40,
              ),
              const SizedBox(width: 10),
              Text("${item['temp'].toStringAsFixed(0)}°C",
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
