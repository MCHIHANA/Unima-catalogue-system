import 'dart:convert';
import 'dart:io';

void downloadBytes(List<int> bytes, String fileName, String mimeType) {
  final outputFile = _resolveOutputFile(fileName);
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsBytesSync(bytes, flush: true);
}

void downloadText(String text, String fileName, String mimeType) {
  final encoded = utf8.encode(text);
  downloadBytes(encoded, fileName, '$mimeType;charset=utf-8');
}

File _resolveOutputFile(String fileName) {
  final downloadsPath = _downloadsDirectoryPath();
  return File('${downloadsPath}${Platform.pathSeparator}$fileName');
}

String _downloadsDirectoryPath() {
  final userProfile = Platform.environment['USERPROFILE'];
  if (userProfile != null && userProfile.isNotEmpty) {
    return '$userProfile${Platform.pathSeparator}Downloads';
  }

  return Directory.current.path;
}
