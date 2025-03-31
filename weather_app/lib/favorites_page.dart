import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> favoriteCities = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteCities = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> removeFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    favoriteCities.remove(city);
    await prefs.setStringList('favorites', favoriteCities);
    setState(() {});
  }

  void navigateToCity(String city) {
    Navigator.pop(context, city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Cities"),
      ),
      body: favoriteCities.isEmpty
          ? const Center(child: Text("Couldn't find any favorite city."))
          : ListView.builder(
        itemCount: favoriteCities.length,
        itemBuilder: (context, index) {
          final city = favoriteCities[index];
          return ListTile(
            title: Text(city),
            leading: const Icon(Icons.location_city),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => removeFavorite(city),
            ),
            onTap: () => navigateToCity(city),
          );
        },
      ),
    );
  }
}
