import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import '../../constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();


}

class _HomePageState extends State<HomePage> {
  String predictionText = 'No prediction yet.'; // Initial prediction text
  File? _selectedImage;
  late String _prediction;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //child: Text('Home Page'),
        child:Padding(
          padding: const EdgeInsets.all(16.0), // Add padding around the content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align content vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Align content horizontally
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
                children: [
                  MaterialButton(
                      color: Colors.white,
                      elevation: 5.0, // Add shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.photo_library,
                            color: Constants.blackColor,
                          ),
                          const SizedBox(width: 8), // Add spacing between icon and text
                          Text(
                            "Gallery",
                            style: TextStyle(
                              color: Constants.blackColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        _pickImageFromGallery();
                      }),
                  MaterialButton(
                      color: Colors.white,
                      elevation: 5.0, // Add shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Constants.blackColor,
                          ),
                          const SizedBox(width: 8), // Add spacing between icon and text
                          Text(
                            "Camera",
                            style: TextStyle(
                              color: Constants.blackColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        _pickImageFromCamera();
                      }),
                ],
              ),

              const SizedBox(
                height: 20,
                width: 20,
              ),
              _selectedImage != null
                  ? Image.file(_selectedImage!)
                  : const Text("Please Select an image"),
              const SizedBox(
                height: 10,
                width: 20,
              ),
              MaterialButton(
                  color: Colors.green,
                  elevation: 5.0, // Add shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: loading
                      ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16, // Specify the size of the progress indicator
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Predicting...",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                      : const Text(
                    "Predict Disease",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    _predictDisease(_selectedImage!);
                  }),
              const SizedBox(height: 20), // Add spacing before the prediction text
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    predictionText,
                    style: const TextStyle(
                      color: Colors.black,
                      height: 1.5, // Adjust line height for readability
                      fontSize: 16, // Set an appropriate font size
                    ),
                    softWrap: true, // Allow wrapping of text
                    overflow: TextOverflow.visible, // Ensure all text is displayed
                  ),
                ),
              ),
            ],
          ),
        )

      ),
    );
  }

  Future _pickImageFromGallery() async {
    final XFile? returnedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) {
      print('No image was picked.');
      return;
    }
    // Convert XFile to File
    final File imageFile = File(returnedImage.path);
    // Step 2: Resize the image
    final resizedFile = await resizeImage(imageFile);
    if (resizedFile != null) {
      print('Resized image saved at: ${resizedFile.path}');
    } else {
      print('Failed to resize the image.');
    }

    if (resizedFile == null) return;
    setState(() {
      _selectedImage = File(resizedFile.path);
    });
  }

  Future _pickImageFromCamera() async {
    final XFile? returnedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) {
      print('No image was picked.');
      return;
    }
    // Convert XFile to File
    final File imageFile = File(returnedImage.path);
    // Step 2: Resize the image
    final resizedFile = await resizeImage(imageFile);
    if (resizedFile != null) {
      print('Resized image saved at: ${resizedFile.path}');
    } else {
      print('Failed to resize the image.');
    }

    if (resizedFile == null) return;
    setState(() {
      _selectedImage = File(resizedFile.path);
    });
  }

  Future<File?> resizeImage(File imageFile) async {
    // Read the image file as bytes
    final bytes = await imageFile.readAsBytes();

    // Decode the image
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) return null;

    // Resize the image
    final resizedImage = img.copyResize(
      originalImage,
      width: 200, // Set the desired width
      height: 200, // Set the desired height (optional)
    );

    // Save the resized image to a new file
    final resizedFile = File(
        imageFile.path.replaceFirst('.jpg', '_resized.jpg'))
      ..writeAsBytesSync(img.encodeJpg(resizedImage));

    return resizedFile;
  }

  Future _predictDisease(File imageFile,) async {
    try {
      // Create a Multipart Request
      final request = http.MultipartRequest(
          'POST', Uri.parse('http://10.0.2.2:8000/predict'));
      setState(() {
        loading = true;
      });

      // Attach the image file
      request.files.add(await http.MultipartFile.fromPath(
        'file', // Key expected by the API
        imageFile.path,
      ));

      // Send the request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        // Parse the response

        print(responseData);
        final Map<String, dynamic> jsonResponse = json.decode(responseData);
        final String prediction = jsonResponse['prediction'];

        if(prediction=="Unhealthy Leaf"){
          final String disease = jsonResponse['disease'];
          final String recommendation = jsonResponse['recommendation'];

          setState(() {
            predictionText = "$prediction having $disease. \nRecommendations for this disease is : $recommendation";
          });
        }else{
          setState(() {
            predictionText = "$prediction ";
          });
        }

        setState(() {
          loading = false;
        });
        // Update the UI
      } else {
        setState(() {
          predictionText = 'Error: Failed to get prediction';
        });
      }
    } catch (e) {
      setState(() {
        predictionText = 'Error: $e';
      });
    }
  }
}
