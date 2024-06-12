import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ArtistInfoScreen extends StatefulWidget {
  final String artistName;

  const ArtistInfoScreen({Key? key, required this.artistName}) : super(key: key);

  @override
  _ArtistInfoScreenState createState() => _ArtistInfoScreenState();
}

class _ArtistInfoScreenState extends State<ArtistInfoScreen> {
  String? _artistInfo;
  String? _wikipediaUrl;

  @override
  void initState() {
    super.initState();
    _fetchArtistInfo();
  }

  Future<void> _fetchArtistInfo() async {
    final url = 'https://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exintro=&titles=${widget.artistName}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pages = data['query']['pages'];
      if (pages.isNotEmpty) {
        final page = pages.values.first;
        setState(() {
          _artistInfo = page['extract'];
          _wikipediaUrl = 'https://en.wikipedia.org/wiki/${widget.artistName.replaceAll(' ', '_')}';
        });
      }
    } else {
      setState(() {
        _artistInfo = 'Failed to load artist info.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artistName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _artistInfo != null
            ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _artistInfo!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (_wikipediaUrl != null)
                const Text(
                  'Source: Wikipedia',
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
            ],
          ),
        )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
