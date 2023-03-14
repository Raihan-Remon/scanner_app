import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ScannerState();
  }
}

class _ScannerState extends State<Scanner> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> image = [];
  var pageFormat = "A4";

  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
        if (pickedFile != null) {
          image.add(File(pickedFile.path));
        }
      },
    );
  }

  getImageFromCam() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        image.add(File(pickedFile.path));
      }
    });
  }

  Future<Uint8List> generateDocument(
      PdfPageFormat format, imageLength, image) async {
    final doc = pw.Document(pageMode: PdfPageMode.outlines);

    final font = await PdfGoogleFonts.openSansRegular();

    for (var i in image) {
      final showImage = pw.MemoryImage(i.readAsBytesSync());

      doc.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: format.copyWith(
              marginBottom: 0,
              marginLeft: 0,
              marginRight: 0,
              marginTop: 0,
            ),
            orientation: pw.PageOrientation.portrait,
            theme: pw.ThemeData.withFont(
              base: font,
            ),
          ),
          build: (context) {
            return pw.Center(
              child: pw.Image(showImage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    return await doc.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          image.isEmpty
              ? Center(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Select Image From Camera or Gallery',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : PdfPreview(
                  maxPageWidth: 1000,
                  canChangeOrientation: true,
                  build: (format) => generateDocument(
                    format,
                    image.length,
                    image,
                  ),
                ),
          Align(
            alignment: const Alignment(0.5, 0.8),
            child: FloatingActionButton(
              elevation: 0,
              onPressed: getImageFromGallery,
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.browse_gallery),
            ),
          ),
          Align(
            alignment: const Alignment(-0.5, 0.8),
            child: FloatingActionButton(
              elevation: 0,
              onPressed: getImageFromCam,
              backgroundColor: Colors.blueGrey,
              child: const Icon(Icons.add_a_photo),
            ),
          ),
        ],
      ),
    );
  }
}
