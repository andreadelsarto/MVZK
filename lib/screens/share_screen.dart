import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ShareScreen extends StatefulWidget {
  final Uint8List image; // Immagine blurrata originale
  final String artistName;
  final String songTitle;
  final Color accentColor;

  const ShareScreen({
    Key? key,
    required this.image,
    required this.artistName,
    required this.songTitle,
    required this.accentColor,
  }) : super(key: key);

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  bool _includeText = true; // Per controllare se includere il testo nell'immagine condivisa
  GlobalKey _globalKey = GlobalKey(); // Chiave per identificare il widget della miniatura

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Condividi'),
        backgroundColor: widget.accentColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Miniatura dell'immagine e Dettagli Canzone
            RepaintBoundary(
              key: _globalKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    width: 200, // Dimensioni della miniatura
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(widget.image),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          widget.accentColor.withOpacity(0.5),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: _includeText
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.songTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2.0,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'di ${widget.artistName}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2.0,
                                color: Colors.black38,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'su MVZK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2.0,
                                color: Colors.black38,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                        : Container(),
                  ),
                ),
              ),
            ),
            // Pulsanti di Azione
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Includi testo nella condivisione'),
                    value: _includeText,
                    onChanged: (bool value) {
                      setState(() {
                        _includeText = value;
                      });
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _shareContent(context),
                    icon: Icon(Icons.share),
                    label: Text('Condividi con...'),
                    style: ElevatedButton.styleFrom(backgroundColor: widget.accentColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareContent(BuildContext context) async {
    try {
      // Ottieni la render box del widget della miniatura
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Converti il widget in un'immagine
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Salva l'immagine come file temporaneo
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/shared_image.png';
      final file = await File(filePath).create();
      await file.writeAsBytes(pngBytes);

      // Condividi l'immagine salvata utilizzando shareXFiles
      Share.shareXFiles(
        [XFile(file.path)],
        text: _includeText
            ? 'Sto ascoltando "${widget.songTitle}" di ${widget.artistName} su MVZK!'
            : null,
      );
    } catch (e) {
      print('Errore durante la condivisione: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante la condivisione')),
      );
    }
  }
}
