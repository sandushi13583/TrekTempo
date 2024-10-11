// places of distrcits

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:travel_app/Models/Place.dart';
import 'package:travel_app/Pages/Destinations/district_places_card.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DestinationCard extends StatefulWidget {
  final String district;

  const DestinationCard({super.key, required this.district});

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  Future<List<Place>>? futurePlaces;

  @override
  void initState() {
    super.initState();
    futurePlaces = fetchPlacesData(widget.district);
  }

  Future<List<Place>> fetchPlacesData(String district) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/getPlaces/$district'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        List<dynamic> placesJson = jsonData['places'];

        return placesJson
            .map((placeJson) => Place.fromJson(placeJson))
            .toList();
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.district),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Place>>(
        future: futurePlaces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.blueAccent,
              size: 50,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No places found.'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final place = snapshot.data![index];
                return Column(
                  children: [
                    PlacesCard(
                      district: place.district,
                      imagePaths: place.images,
                      title: place.name,
                      location: place.location,
                      description: place.description,
                      likes: place.likes,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
