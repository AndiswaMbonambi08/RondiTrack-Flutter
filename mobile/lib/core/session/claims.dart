import 'dart:convert';

/// Reads the claims of a token WITHOUT checking its signature. Only for
/// showing or keying things on the client. The API is what checks tokens.
Map<String, dynamic> readClaims(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) throw const FormatException('Not a token.');
  final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  return jsonDecode(json) as Map<String, dynamic>;
}

String? subjectOf(String? jwt) {
  if (jwt == null) return null;
  try {
    final sub = readClaims(jwt)['sub'];
    return sub is String ? sub : null;
  } on Object {
    return null;
  }
}
