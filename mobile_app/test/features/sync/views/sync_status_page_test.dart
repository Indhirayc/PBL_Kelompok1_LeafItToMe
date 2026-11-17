import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/providers/database_providers.dart';
import 'package:mobile_app/core/sync/sync_manager.dart';
import 'package:mobile_app/data/models/scan_record_model.dart';
import 'package:mobile_app/features/sync/views/sync_status_page.dart';

import '../fake_scan_repository.dart';

class _TestUserIdNotifier extends CurrentUserIdNotifier {
  @override
  String build() => 'user-local';
}

class _MutableScanRepository extends FakeScanRepository {
  _MutableScanRepository({
    required List<ScanRecordModel> initialScans,
    required this.result,
    this.syncCompleter,
  }) : _pendingScans = List.of(initialScans),
       super(pendingScans: initialScans, syncResult: result);

  final List<ScanRecordModel> _pendingScans;
  final SyncBatchResult result;
  final Completer<SyncBatchResult>? syncCompleter;

  @override
  Future<List<ScanRecordModel>> getUnsyncedScans(String userId) async =>
      List.of(_pendingScans);

  @override
  Future<SyncBatchResult> triggerSync(String userId) async {
    syncCallCount++;
    final syncResult = syncCompleter == null
        ? result
        : await syncCompleter!.future;
    _pendingScans.removeWhere((scan) => syncResult.syncedIds.contains(scan.id));
    return syncResult;
  }
}

ScanRecordModel _scan({
  required String id,
  required String plantName,
  required String diseaseName,
  required DateTime scannedAt,
}) {
  return ScanRecordModel(
    id: id,
    userId: 'user-local',
    plantName: plantName,
    diseaseName: diseaseName,
    confidence: 0.9,
    localImagePath: '',
    scannedAt: scannedAt,
  );
}

Future<void> _pumpPage(
  WidgetTester tester,
  FakeScanRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWith(_TestUserIdNotifier.new),
        scanRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: SyncStatusPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menampilkan antrean tanpa kontrol simulasi', (tester) async {
    final repository = FakeScanRepository(
      pendingScans: [
        _scan(
          id: 'S-001',
          plantName: 'Tomat Pot Depan',
          diseaseName: 'Bacterial Spot',
          scannedAt: DateTime(2026, 9, 18),
        ),
        _scan(
          id: 'S-002',
          plantName: 'Tomat Kebun Belakang',
          diseaseName: 'Leaf Mold',
          scannedAt: DateTime(2026, 9, 26),
        ),
      ],
    );

    await _pumpPage(tester, repository);

    expect(find.text('Sinkronisasi Data'), findsOneWidget);
    expect(find.text('Sinkronisasi Cloud'), findsOneWidget);
    expect(find.text('2 data belum disinkronkan'), findsOneWidget);
    expect(find.text('Tomat Pot Depan'), findsOneWidget);
    expect(find.text('Bacterial Spot  •  18 Sep 2026'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    expect(find.text('Simulasikan sinkronisasi gagal'), findsNothing);
    expect(find.text('Sinkronkan Sekarang'), findsOneWidget);
  });

  testWidgets('memproses dan menampilkan hasil di halaman yang sama', (
    tester,
  ) async {
    final completer = Completer<SyncBatchResult>();
    final repository = _MutableScanRepository(
      initialScans: [
        _scan(
          id: 'S-001',
          plantName: 'Tomat Pot Depan',
          diseaseName: 'Bacterial Spot',
          scannedAt: DateTime(2026, 9, 18),
        ),
      ],
      result: const SyncBatchResult(syncedIds: ['S-001'], failedIds: []),
      syncCompleter: completer,
    );
    await _pumpPage(tester, repository);

    await tester.tap(find.byKey(const Key('syncNowButton')));
    await tester.pump();

    expect(find.text('Sinkronisasi sedang berlangsung...'), findsOneWidget);
    expect(find.text('Sinkronisasi Data'), findsOneWidget);
    expect(repository.syncCallCount, 1);

    completer.complete(repository.result);
    await tester.pumpAndSettle();

    expect(find.text('Sinkronisasi Berhasil'), findsOneWidget);
    expect(find.text('1 data berhasil disinkronkan.'), findsOneWidget);
    expect(find.text('0 data belum disinkronkan'), findsOneWidget);
    expect(find.text('Sinkronisasi Data'), findsOneWidget);
    expect(find.text('Menyinkronkan...'), findsNothing);
  });

  testWidgets('menampilkan detail jika sinkronisasi gagal', (tester) async {
    final repository = _MutableScanRepository(
      initialScans: [
        _scan(
          id: 'S-001',
          plantName: 'Tomat Pot Depan',
          diseaseName: 'Bacterial Spot',
          scannedAt: DateTime(2026, 9, 18),
        ),
      ],
      result: const SyncBatchResult(
        syncedIds: [],
        failedIds: ['S-001'],
        errors: ['S-001: permission-denied'],
      ),
    );
    await _pumpPage(tester, repository);

    await tester.tap(find.byKey(const Key('syncNowButton')));
    await tester.pumpAndSettle();

    expect(find.text('Sinkronisasi Gagal'), findsOneWidget);
    expect(find.text('0 berhasil, 1 masih tertunda.'), findsOneWidget);
    expect(find.text('S-001: permission-denied'), findsOneWidget);
    expect(find.text('1 data belum disinkronkan'), findsOneWidget);
    expect(find.text('Sinkronkan Sekarang'), findsOneWidget);
    expect(find.text('Sinkronisasi Data'), findsOneWidget);
  });
}
