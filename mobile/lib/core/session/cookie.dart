class MissingCookieError implements Exception {
  const new(this.name);

  final String name;

  @override
  String toString() => 'MissingCookieError: no "$name" cookie in the response';
}

/// Reads one cookie's value by name from the Set-Cookie lines of a response.
/// Throws when the cookie is not there or is empty.
String readSetCookie(Iterable<String>? lines, String name) {
  for (final line in lines ?? const <String>[]) {
    final pair = line.split(';').first.trim();
    final eq = pair.indexOf('=');
    if (eq <= 0 || pair.substring(0, eq).trim() != name) continue;
    final value = pair.substring(eq + 1).trim();
    if (value.isNotEmpty) return value;
  }
  throw MissingCookieError(name);
}
