import 'package:flutter/material.dart';
import 'main_page.dart';
import 'search_page.dart';
import 'favorites_page.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainNavigationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  String _currentCity = "Eskişehir";

  void _onItemTapped(int index) async {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 2) {
      final selectedCity = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoritesPage()),
      );

      if (selectedCity != null && selectedCity is String) {
        setState(() {
          _currentCity = selectedCity;
          _selectedIndex = 0;
        });
      }
    }
  }

  void _openSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );

    if (result != null && result is String) {
      setState(() {
        _currentCity = result;
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? WeatherHomePage(cityName: _currentCity)
          : const FavoritesPage(),

      floatingActionButton: FloatingActionButton(
        onPressed: _openSearch,
        tooltip: 'Search a City',
        child: const Icon(Icons.search),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => _onItemTapped(0),
                tooltip: "Main Page",
              ),
              IconButton(
                icon: const Icon(Icons.star),
                onPressed: () => _onItemTapped(2),
                tooltip: "Favorites",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
