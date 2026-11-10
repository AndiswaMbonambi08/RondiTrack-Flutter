import 'package:ronditrack/features/stokvel/domain/models.dart';

abstract interface class StokvelRepository {
  /// Throws NotFoundException for a missing stokvel AND for one the caller is
  /// not a member of (same as the API's 404).
  Future<StokvelDetail> fetchDetail(String id);
}
