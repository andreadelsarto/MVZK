import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class ImageService {
  static const String _apiUrl = 'https://en.wikipedia.org/w/api.php?action=query&prop=pageimages&format=json&pithumbsize=500&titles=';

  static Future<Map<String, Uint8List?>> fetchArtistImage(String artistName) async {
    final primaryArtist = _extractPrimaryArtist(artistName);
    print('Primary artist: $primaryArtist');

    final cacheDir = await getTemporaryDirectory();
    final cachedImagePath = '${cacheDir.path}/$primaryArtist.jpg';

    if (await File(cachedImagePath).exists()) {
      print('Loading image from cache');
      final cachedImage = await File(cachedImagePath).readAsBytes();
      final blurredImage = await _blurImage(cachedImage);
      return {'original': cachedImage, 'blurred': blurredImage};
    }

    final url = '$_apiUrl$primaryArtist';
    print('Fetching image from: $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pages = data['query']['pages'];
      if (pages != null) {
        for (var pageId in pages.keys) {
          final page = pages[pageId];
          if (page['thumbnail'] != null && page['thumbnail']['source'] != null) {
            final imageUrl = page['thumbnail']['source'];
            final imageResponse = await http.get(Uri.parse(imageUrl));
            if (imageResponse.statusCode == 200) {
              print('Image fetched successfully');
              final originalImage = imageResponse.bodyBytes;

              await File(cachedImagePath).writeAsBytes(originalImage);

              final blurredImage = await _blurImage(originalImage);
              return {'original': originalImage, 'blurred': blurredImage};
            } else {
              print('Failed to fetch image. Status code: ${imageResponse.statusCode}');
            }
          }
        }
      } else {
        print('No image found for the artist');
      }
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
    return {'original': null, 'blurred': null};
  }

  static String _extractPrimaryArtist(String artistName) {
    final regex = RegExp(r'(feat\.|,|&|ft\.|\(|\))', caseSensitive: false);
    final match = artistName.split(regex);
    return match.isNotEmpty ? match[0].trim() : artistName;
  }

  static Future<Uint8List> _blurImage(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    final blurredImage = img.gaussianBlur(image!, 10); // Adjust the value '10' to control the blur amount
    return Uint8List.fromList(img.encodeJpg(blurredImage));
  }
}
