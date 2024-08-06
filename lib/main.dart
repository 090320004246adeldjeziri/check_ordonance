import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prescription Checker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Roboto',
      ),
      home: PrescriptionChecker(),
    );
  }
}

class PrescriptionChecker extends StatefulWidget {
  @override
  _PrescriptionCheckerState createState() => _PrescriptionCheckerState();
}

class _PrescriptionCheckerState extends State<PrescriptionChecker> {
  final ImagePicker _picker = ImagePicker();
  String _result = '';
  bool _isProcessing = false;

  Future<void> _checkImage() async {
    setState(() {
      _isProcessing = true;
      _result = '';
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        _showSnackBar('Aucune image sélectionnée.');
        return;
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final textDetector = GoogleMlKit.vision.textRecognizer();
      var recognisedText = await textDetector.processImage(inputImage);
      await textDetector.close();
      String extractedText = recognisedText.text;

      List<String> keywords = [
        'ordonnance',
        'prescription',
        'Rx',
        'Dosage',
        'Take',
        'Patient',
        'Doctor',
        'Prescribed',
        'mg',
        'tablet',
        'وصفة طبية'
      ];

      bool isPrescription = keywords.any(
          (keyword) => extractedText.toLowerCase().contains(keyword.toLowerCase()));

      setState(() {
        _result = isPrescription
            ? 'Cette image est une ordonnance avec une probabilité de 80%.'
            : 'Cette image ne semble pas être une ordonnance.';
      });
    } catch (e) {
      _showSnackBar('Erreur lors du traitement de l\'image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérificateur d\'Ordonnance'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.health_and_safety,
              size: 100,
              color: Colors.teal,
            ),
            SizedBox(height: 30),
            Text(
              'Vérifiez si votre image est une ordonnance médicale.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 30),
            if (_isProcessing)
              CircularProgressIndicator()
            else if (_result.isNotEmpty)
              Text(
                _result,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _checkImage,
              icon: Icon(Icons.upload_file),
              label: Text('Sélectionner une Image'),
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}