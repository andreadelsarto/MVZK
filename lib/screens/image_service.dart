import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class ImageService {
  static const String _apiUrl =
      'https://en.wikipedia.org/w/api.php?action=query&prop=pageimages&format=json&pithumbsize=500&titles=';

  static Future<Map<String, Uint8List?>> fetchArtistImage(
      String artistName, Color accentColor) async {
    final primaryArtist = _extractPrimaryArtist(artistName);
    print('Primary artist: $primaryArtist');

    final cacheDir = await getTemporaryDirectory();
    final cachedImagePath = '${cacheDir.path}/$primaryArtist.jpg';

    if (await File(cachedImagePath).exists()) {
      print('Loading image from cache');
      final cachedImage = await File(cachedImagePath).readAsBytes();
      final processedImage = await _processImage(cachedImage, accentColor);
      return {'original': cachedImage, 'blurred': processedImage};
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

              final processedImage =
              await _processImage(originalImage, accentColor);
              return {'original': originalImage, 'blurred': processedImage};
            } else {
              print(
                  'Failed to fetch image. Status code: ${imageResponse.statusCode}');
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

  static Future<Uint8List> _processImage(
      Uint8List imageBytes, Color accentColor) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      return imageBytes;
    }

    // Converti l'immagine in bianco e nero
    final grayscaleImage = img.grayscale(image);

    // Applica il colore accento
    final coloredImage = _applyAccentColor(grayscaleImage, accentColor);

    // Sfoca l'immagine
    final blurredImage = img.gaussianBlur(coloredImage, 10);

    return Uint8List.fromList(img.encodeJpg(blurredImage));
  }

  static img.Image _applyAccentColor(img.Image image, Color accentColor) {
    final accent = img.getColor(
      accentColor.red,
      accentColor.green,
      accentColor.blue,
    );

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final gray = img.getLuminance(pixel); // Calcola la luminosità
        final tintedPixel = img.getColor(
          (gray * accentColor.red / 255).toInt(),
          (gray * accentColor.green / 255).toInt(),
          (gray * accentColor.blue / 255).toInt(),
        );
        image.setPixel(x, y, tintedPixel);
      }
    }

    return image;
  }
}
