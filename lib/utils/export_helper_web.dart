import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Triggers a browser download of [bytes] with the given [fileName] and [mimeType].
void downloadBytes(List<int> bytes, String fileName, String mimeType) {
  final uint8List = Uint8List.fromList(bytes);
  final blob = web.Blob([uint8List.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  _triggerDownload(blob, fileName);
}

/// Triggers a browser download of [text] with the given [fileName] and [mimeType].
void downloadText(String text, String fileName, String mimeType) {
  final encoded = utf8.encode(text);
  downloadBytes(encoded, fileName, '$mimeType;charset=utf-8');
}

void _triggerDownload(web.Blob blob, String fileName) {
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName;
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
