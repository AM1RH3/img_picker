import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:img_picker/image_cropper.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<Face> _faces = [];

  final facedetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));

  XFile? _optedImage;
  Uint8List? _optedImageData;

  final _border =
      const Border(top: BorderSide(width: 1, color: Colors.black26));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    facedetector.close();
    super.dispose();
  }

  void _pickImage() async {
    _optedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (_optedImage != null) {
      _optedImageData = await _optedImage!.readAsBytes();
      _detectFaces();
    }
  }

  void _detectFaces() async {
    final faces = await facedetector
        .processImage(InputImage.fromFilePath(_optedImage!.path));
    //! ... is clear first then replace new face
    _faces = [...faces];

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Flexible(
                flex: 2,
                child: Container(
                  color: Colors.white,
                  child: _optedImage != null
                      ? Image.file(
                          File(_optedImage!.path),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  decoration:
                      BoxDecoration(color: Colors.white, border: _border),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _optedImage != null
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemCount: _faces.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(2),
                                child: ImageCropperWidget(
                                  orginalImageData: _optedImageData!,
                                  rect: _faces[index].boundingBox,
                                ),
                              );
                            },
                          )
                        : Container(),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FloatingActionButton(
                onPressed: _pickImage,
                child: const Icon(Icons.face),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
