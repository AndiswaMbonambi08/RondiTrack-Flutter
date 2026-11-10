import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/home/domain/home_repository.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_repository.dart';

class StubHomeRepository implements HomeRepository {
  StubHomeRepository(this._fetch);

  final Future<List<HomeEntry>> Function() _fetch;

  @override
  Future<List<HomeEntry>> fetchHome() => _fetch();
}

class StubStokvelRepository implements StokvelRepository {
  StubStokvelRepository(this._fetch);

  final Future<StokvelDetail> Function(String id) _fetch;

  @override
  Future<StokvelDetail> fetchDetail(String id) => _fetch(id);
}
