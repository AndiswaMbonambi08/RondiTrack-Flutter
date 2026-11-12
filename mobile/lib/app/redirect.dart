const signInPath = '/sign-in';

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

/// One function decides every navigation from the auth state and the
/// address. It needs no widget, so it is tested directly.
///
/// Signed out: everything goes to sign-in, carrying the address in `from`.
/// Signed in on sign-in: go to `from` when it is inside the app, else Home.
String? redirectFor({required bool signedIn, required Uri location}) {
  final onSignIn = location.path == signInPath;
  if (!signedIn) {
    if (onSignIn) return null;
    final from = location.toString();
    if (from == '/' || !isInAppAddress(from)) return signInPath;
    return Uri(path: signInPath, queryParameters: {'from': from}).toString();
  }
  if (onSignIn) {
    final from = location.queryParameters['from'];
    return isInAppAddress(from) ? from : '/';
  }
  return null;
}
