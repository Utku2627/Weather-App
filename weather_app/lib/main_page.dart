import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'forecast_section.dart';

class WeatherHomePage extends StatefulWidget {
  final String cityName;

  const WeatherHomePage({super.key, this.cityName = "Eskişehir"});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String city = "";
  String description = "";
  String iconCode = "";
  double temp = 0;
  double feelsLike = 0;
  int humidity = 0;
  double windSpeed = 0;
  int windDeg = 0;
  int cloudiness = 0;
  bool isFavorite = false;
  String localTime = "";

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchWeather(widget.cityName);
  }

  @override
  void didUpdateWidget(covariant WeatherHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cityName != widget.cityName) {
      _scrollController.jumpTo(0);
      fetchWeather(widget.cityName);
    }
  }

  Future<void> fetchWeather(String cityName) async {
    const apiKey = "8e66025cad9a10b209e91404f24cafd6";
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric&lang=en",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          city = data["name"];
          description = data["weather"][0]["description"];
          iconCode = data["weather"][0]["icon"];
          temp = data["main"]["temp"];
          feelsLike = data["main"]["feels_like"];
          humidity = data["main"]["humidity"];
          windSpeed = data["wind"]["speed"];
          windDeg = data["wind"]["deg"];
          cloudiness = data["clouds"]["all"];
          localTime = getLocalTime(data["timezone"]);
        });
        checkIfFavorite(city);
      } else {
        showError("Failed to fetch data. (${response.statusCode})");
      }
    } catch (e) {
      showError("An error occurred: $e");
    }
  }

  String getLocalTime(int timezoneOffsetInSeconds) {
    final utcNow = DateTime.now().toUtc();
    final local = utcNow.add(Duration(seconds: timezoneOffsetInSeconds));
    return "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> checkIfFavorite(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(cityName);
    });
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    if (isFavorite) {
      favorites.remove(city);
    } else {
      favorites.add(city);
    }
    await prefs.setStringList('favorites', favorites);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  String getWindDirectionName(int degree) {
    if (degree >= 337.5 || degree < 22.5) return "North";
    if (degree >= 22.5 && degree < 67.5) return "Northeast";
    if (degree >= 67.5 && degree < 112.5) return "East";
    if (degree >= 112.5 && degree < 157.5) return "Southeast";
    if (degree >= 157.5 && degree < 202.5) return "South";
    if (degree >= 202.5 && degree < 247.5) return "Southwest";
    if (degree >= 247.5 && degree < 292.5) return "West";
    if (degree >= 292.5 && degree < 337.5) return "Northwest";
    return "Unknown";
  }

  Widget getBackgroundAnimation() {
    final lowerDesc = description.toLowerCase();

    if (lowerDesc.contains("thunder") || lowerDesc.contains("storm")) {
      return Transform.translate(
        offset: const Offset(-60, 0),
        child: Lottie.asset('assets/lottie/thunderstormy.json', fit: BoxFit.cover),
      );
    } else if (lowerDesc.contains("mist") || lowerDesc.contains("fog")) {
      return Lottie.asset('assets/lottie/misty.json', fit: BoxFit.cover);
    } else if (lowerDesc.contains("clear")) {
      return Lottie.asset('assets/lottie/sunny.json', fit: BoxFit.cover);
    } else if (lowerDesc.contains("rain")) {
      return Lottie.asset('assets/lottie/rainy.json', fit: BoxFit.cover);
    } else if (lowerDesc.contains("cloud")) {
      return Lottie.asset('assets/lottie/cloudy.json', fit: BoxFit.cover);
    } else if (lowerDesc.contains("snow")) {
      return Lottie.asset('assets/lottie/snowy.json', fit: BoxFit.cover);
    } else {
      return const SizedBox.shrink();
    }
  }

  Color getBaseColor() {
    final lowerDesc = description.toLowerCase();
    if (lowerDesc.contains("clear")) return Colors.orange.shade100;
    if (lowerDesc.contains("rain") || lowerDesc.contains("thunder")) return Colors.blueGrey.shade800;
    if (lowerDesc.contains("cloud")) return Colors.grey.shade500;
    if (lowerDesc.contains("snow")) return Colors.blue.shade100;
    if (lowerDesc.contains("mist") || lowerDesc.contains("fog")) return Colors.grey.shade400;
    return Colors.lightBlue.shade100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: Colors.yellow,
            ),
            onPressed: toggleFavorite,
            tooltip: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(color: getBaseColor()),
          Positioned.fill(child: getBackgroundAnimation()),
          Container(
            color: Colors.black.withAlpha(77),
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              controller: _scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(city,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(localTime,
                        style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    iconCode.isNotEmpty
                        ? Image.network(
                      "https://openweathermap.org/img/wn/$iconCode@2x.png",
                      width: 70,
                      height: 70,
                    )
                        : const SizedBox(width: 70, height: 70),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${temp.toStringAsFixed(1)}°C", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text("Feels like: ${feelsLike.toStringAsFixed(1)}°C", style: const TextStyle(fontSize: 16, color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text("Humidity: $humidity%", style: const TextStyle(fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text("Wind: ${windSpeed.toStringAsFixed(1)} m/s, ${getWindDirectionName(windDeg)}",
                              style: const TextStyle(fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text("☁️ Cloudiness: $cloudiness%",
                              style: const TextStyle(fontSize: 14, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (city.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const Text("Hourly Forecast",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  HourlyForecastSection(cityName: city),
                  const SizedBox(height: 28),
                  const Text("5-Day Forecast",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  DailyForecastSection(cityName: city),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
