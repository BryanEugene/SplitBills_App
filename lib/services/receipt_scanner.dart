import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScanner {
  final _textRecognizer = TextRecognizer();
  final _imagePicker = ImagePicker();

  Future<List<String>> scanReceipt() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return [];

    final inputImage = InputImage.fromFilePath(image.path);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    
    return _parseReceiptText(recognizedText.text);
  }

  List<String> _parseReceiptText(String text) {
    final lines = text.split('\n');
    return lines.where((line) => 
      RegExp(r'\$?\d+\.?\d*').hasMatch(line)).toList();
  }

  void dispose() {
    _textRecognizer.close();
  }
}
