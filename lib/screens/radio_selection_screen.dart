import 'package:flutter/material.dart';
import 'radio_player_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RadioSelectionScreen extends StatefulWidget {
  @override
  _RadioSelectionScreenState createState() => _RadioSelectionScreenState();
}

class _RadioSelectionScreenState extends State<RadioSelectionScreen> {
  List<Map<String, String>> _savedStations = [
    {
      'name': 'Jazz FM',
      'url': 'https://jazzfm-streaming-url.example.com/stream'
    },
    {
      'name': 'Rock Radio',
      'url': 'https://rockradio-streaming-url.example.com/stream'
    },
  ];

  List<Map<String, String>> _searchResults = [];
  bool _isLoading = false;

  // Stazioni suggerite
  final List<Map<String, String>> _suggestedStations = [
    {
      'name': 'BBC Radio 1',
      'url': 'http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1_mf_p'
    },
    {
      'name': 'Jazz24',
      'url': 'https://live.wostreaming.net/direct/ppm-jazz24mp3-ibc1'
    },
    {
      'name': 'Classic FM',
      'url': 'http://media-ice.musicradio.com/ClassicFMMP3'
    },
  ];

  Future<void> _searchStations(String query) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('https://de1.api.radio-browser.info/json/stations/search?name=$query'));

    if (response.statusCode == 200) {
      final List<dynamic> stations = json.decode(response.body);
      setState(() {
        _searchResults = stations.map((station) {
          // Assicurati che i valori siano convertiti in stringhe
          return {
            'name': station['name']?.toString() ?? 'Unknown Station',
            'url': station['url']?.toString() ?? '',
          };
        }).toList();
      });
    } else {
      print('Errore nella ricerca delle stazioni radio: ${response.reasonPhrase}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _addStation(String name, String url) {
    setState(() {
      _savedStations.add({'name': name, 'url': url});
    });
  }

  void _navigateToPlayer(String name, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RadioPlayerScreen(
          stationName: name,
          stationUrl: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Seleziona Radio',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.primary),
            onPressed: () async {
              final query = await showSearch(
                context: context,
                delegate: RadioSearchDelegate(
                  searchFunction: _searchStations,
                  suggestedStations: _suggestedStations,
                  addStationCallback: _addStation,
                ),
              );
              if (query != null) {
                _searchStations(query);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          ..._savedStations.map((station) {
            return ListTile(
              title: Text(
                station['name']!,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onBackground,
                  fontSize: 24,
                ),
              ),
              trailing: Icon(Icons.play_arrow, color: theme.colorScheme.primary),
              onTap: () => _navigateToPlayer(station['name']!, station['url']!),
            );
          }).toList(),
          if (_searchResults.isNotEmpty) ...[
            Divider(),
            Text(
              'Risultati di ricerca',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onBackground,
              ),
            ),
            ..._searchResults.map((station) {
              return ListTile(
                title: Text(
                  station['name']!,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontSize: 24,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add, color: theme.colorScheme.primary),
                  onPressed: () => _addStation(station['name']!, station['url']!),
                ),
                onTap: () => _navigateToPlayer(station['name']!, station['url']!),
              );
            }).toList(),
          ]
        ],
      ),
    );
  }
}

class RadioSearchDelegate extends SearchDelegate<String> {
  final Future<void> Function(String) searchFunction;
  final List<Map<String, String>> suggestedStations;
  final Function(String, String) addStationCallback;

  RadioSearchDelegate({
    required this.searchFunction,
    required this.suggestedStations,
    required this.addStationCallback,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    searchFunction(query);
    return Center(child: CircularProgressIndicator());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = query.isEmpty ? suggestedStations : [];

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final station = suggestions[index];
        return ListTile(
          title: Text(
            station['name']!,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onBackground,
              fontSize: 24,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.add, color: theme.colorScheme.primary),
            onPressed: () => addStationCallback(station['name']!, station['url']!),
          ),
          onTap: () {
            close(context, station['name']);
            addStationCallback(station['name']!, station['url']!);
          },
        );
      },
    );
  }
}
