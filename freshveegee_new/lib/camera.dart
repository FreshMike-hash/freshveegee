import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FruitScanner extends StatefulWidget {
  const FruitScanner({super.key});

  @override
  _FruitScannerState createState() => _FruitScannerState();
}

class _FruitScannerState extends State<FruitScanner> {
  File? _selectedImage;
  String _result = "Choose Camera or Gallery to Classify";
  bool _isLoading = false;
  late Interpreter _interpreter;

  final List<String> classLabels = [
    'Stale Tomato',
    'Stale Orange',
    'Stale Capsicum',
    'Stale Bitter Groud',
    'Stale Banana',
    'Stale Apple',
    'Fresh Tomato',
    'Fresh Orange',
    'Fresh Capsicum',
    'Fresh Bitter Groud',
    'Fresh Banana',
    'Fresh Apple'
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _requestPermissions();
    await _loadModel();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus storageStatus = await Permission.storage.request();

    if (cameraStatus.isDenied || storageStatus.isDenied) {
      print("Permissions are not granted.");
      if (cameraStatus.isDenied) {
        openAppSettings();
      }
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/model/model_unquant.tflite');
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = "Processing...";
        _isLoading = true;
      });
      _classifyImage(File(pickedFile.path));
    }
  }

  Future<void> _classifyImage(File imageFile) async {
    try {
      img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

      if (image == null) {
        setState(() {
          _result = "Error processing image.";
          _isLoading = false;
        });
        return;
      }

      image = img.copyResize(image, width: 224, height: 224);

      var input = List.generate(1, (index) {
        return List.generate(224, (y) {
          return List.generate(224, (x) {
            img.Pixel? pixel = image?.getPixel(x, y);

            if (pixel == null) {
              return [0.0, 0.0, 0.0];
            }

            var r = pixel.r / 255.0;
            var g = pixel.g / 255.0;
            var b = pixel.b / 255.0;

            return [r, g, b];
          });
        });
      });

      var output = List.filled(1 * 12, 0.0).reshape([1, 12]);

      _interpreter.run(input, output);

      int maxIndex = output[0].indexOf(
          output[0].reduce((a, b) => (a as double) > (b as double) ? a : b));

      String predictedClass =
          classLabels.isNotEmpty ? classLabels[maxIndex] : "Unknown";

      setState(() {
        _result = "Prediction: $predictedClass";
        _isLoading = false;
      });

      if (output[0][maxIndex] < 0.5) {
        setState(() {
          _result = "Uncertain prediction";
        });
      } else {
        _saveScannedDetails(predictedClass);
      }
    } catch (e) {
      print("Error during classification: $e");
      setState(() {
        _result = "Error during classification.";
        _isLoading = false;
      });
    }
  }

  Future<void> _saveScannedDetails(String predictedClass) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in");
        return;
      }

      String dateTime = DateFormat('yyyy-MM-dd – HH:mm').format(DateTime.now());
      String condition = predictedClass.contains('Fresh') ? 'Fresh' : 'Stale';

      Map<String, dynamic> scannedFruit = {
        'fruit_type': predictedClass,
        'condition': condition,
        'date': dateTime.split(" – ")[0],
        'time': dateTime.split(" – ")[1],
        'created_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scanned')
          .add(scannedFruit);

      print("Scanned details saved to Firestore!");
    } catch (e) {
      print("Error saving to Firestore: $e");
    }
  }

  void resetState() {
    setState(() {
      _selectedImage = null;
      _result = "Choose Camera or Gallery to Classify.";
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Fruit & Vegetable Scanner",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0F2A1D),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F2A1D), // Dark green color
                  const Color(0xFF375534), // Medium green color
                  const Color(0xFF6B9071), // Light green color
                  const Color(0xFFAEC3B0), // Light greenish color
                  const Color(0xFFE3EED4), // Light green background
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display image only if selected, remove the placeholder
                if (_selectedImage != null)
                  Image.file(
                    _selectedImage!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 20),
                Text(
                  _result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white), // White text
                ),
                const SizedBox(height: 20),
                if (_isLoading) const CircularProgressIndicator(),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                       ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFF6B9071), 
                          ),
                          label: const Text(
                            "Gallery",
                            style: TextStyle(
                              color: Color(0xFF6B9071), 
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFFE3EED4), 
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(
                            Icons.photo,
                            color: Color(0xFF6B9071), 
                          ),
                          label: const Text(
                            "Gallery",
                            style: TextStyle(
                              color: Color(0xFF6B9071), 
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFFE3EED4), 
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 30),
              onPressed: resetState,
            ),
          ),
        ],
      ),
    );
  }
}
