import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'helper/image_classification_helper.dart';
import 'helper/permission_handler.dart';

Future<void> main() async {
  runApp(const MainView());
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraDescription cameraDescription;

  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;

  PermissionType permission = PermissionType.denied;

  ImageClassificationHelper? imageClassificationHelper;

  final imagePicker = ImagePicker();

  String? imagePath;

  img.Image? image;

  String aiResult = "";

  Map<String, double>? classification;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      permission = await Utils.I.requestPermissionCamera();
      aiResult = "No data...";

      imageClassificationHelper = ImageClassificationHelper();

      imageClassificationHelper!.initHelper();

      setState(() {});
    });
  }

  initPages() async {
    // _widgetOptions = [const GalleryScreen()];

    // if (cameraIsAvailable) {
    //   // get list available camera
    //   cameraDescription = (await availableCameras()).first;
    //   _widgetOptions!.add(CameraScreen(camera: cameraDescription));
    // }

    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tensor Flow Lite",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Expanded(child: _buildFrameImage()),
            const SizedBox(
              height: 48,
            ),
            _buildButtons()
          ],
        ),
      ),
    );
  }

  Widget _buildFrameImage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.3,
          color: Colors.blue,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          if (imagePath != null) Image.file(File(imagePath!)),

          Positioned(
            bottom: 10,
            child: SingleChildScrollView(
              child: Container(
                width: 300,
                child: Column(
                  children: [
                    if (classification != null) ...[
                      if (classification != null)
                        ...(classification!.entries.toList()
                              ..sort(
                                (a, b) => a.value.compareTo(b.value),
                              ))
                            .reversed
                            .take(3)
                            .map(
                              (e) => Container(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Text(
                                      e.key,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Text(
                                      e.value.toStringAsFixed(2),
                                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ],
                    if (classification == null) ...[
                      Text(
                        aiResult,
                        style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),

          // Show model information
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            cleanResult();

            _handlePickImage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Gallery",
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Capture ",
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "Live Camera",
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _handlePickImage() async {
    final result = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    imagePath = result?.path;

    setState(() {});

    processImage();
  }

  // Process picked image
  Future<void> processImage() async {
    if (imagePath != null) {
      // Read image bytes from file
      final imageData = File(imagePath!).readAsBytesSync();

      // Decode image using package:image/image.dart
      image = img.decodeImage(imageData);

      setState(() {});
      classification = await imageClassificationHelper?.inferenceImage(image!);
      setState(() {});
    }
  }

  // Clean old results when press some take picture button
  void cleanResult() {
    imagePath = null;
    image = null;
    classification = null;
    setState(() {});
  }
}
