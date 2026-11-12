import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the manifest claims ronditrack:// links for this flavour only', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android.intent.action.VIEW'));
    expect(manifest, contains('android.intent.category.BROWSABLE'));
    expect(manifest, contains('android:scheme="ronditrack"'));
    // The host is the flavour's own application id, filled in by Gradle.
    expect(manifest, contains(r'android:host="${applicationId}"'));
  });
}
