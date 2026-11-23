import 'package:ronditrack/core/session/auth_state.dart';

const signInPath = '/sign-in';
const registerPath = '/register';
const splashPath = '/splash';

const _knownRoots = {'stokvels', 'activity', 'profile', 'join'};

/// True only for an address inside this app. Anything else is never
/// remembered across sign-in.
bool isInAppAddress(String? address) {
  if (address == null || address.isEmpty) return false;
  if (!address.startsWith('/') || address.startsWith('//')) return false;
  final uri = Uri.tryParse(address);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return false;
  final segments = uri.pathSegments;
  if (segments.isEmpty) return true;
  return _knownRoots.contains(segments.first);
}

/// The invite code in a /join/:code address, or null.
String? joinCodeOf(String? address) {
  if (!isInAppAddress(address)) return null;
  final segments = Uri.parse(address!).pathSegments;
  return segments.length == 2 && segments.first == 'join' ? segments[1] : null;
}

/// One function decides every navigation from the auth state and the
/// address. While restoring every route goes to the splash and remembers
/// where it was going. Signed out goes to sign-in with the same memory.
String? redirectFor({required AuthState auth, required Uri location}) {
  final path = location.path;
  final gate = path == signInPath || path == registerPath || path == splashPath;
  final from = location.queryParameters['from'];
  final target = gate ? from : location.toString();
  String withFrom(String base) {
    if (target == null || target == '/' || !isInAppAddress(target)) return base;
    return Uri(path: base, queryParameters: {'from': target}).toString();
  }

  return switch (auth) {
    Restoring() => path == splashPath ? null : withFrom(splashPath),
    SignedOut() =>
      path == signInPath || path == registerPath ? null : withFrom(signInPath),
    SignedIn() => gate ? (isInAppAddress(from) ? from : '/') : null,
  };
}
