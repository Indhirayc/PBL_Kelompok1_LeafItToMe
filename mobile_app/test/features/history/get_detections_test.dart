import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/core/errors/failures.dart';
import 'package:mobile_app/features/history/domain/entities/detection.dart';
import 'package:mobile_app/features/history/domain/repositories/detection_repository.dart';
import 'package:mobile_app/features/history/domain/usecases/get_detections.dart';

class FakeDetectionRepository implements DetectionRepository {
  FakeDetectionRepository({this.items = const <Detection>[], this.fail = false});

  final List<Detection> items;
  final bool fail;

  @override
  Future<({List<Detection> detections, Failure? failure})> getDetections() async {
    if (fail) {
      return (
        detections: const <Detection>[],
        failure: const LocalFailure('database terkunci (simulasi)'),
      );
    }
    return (detections: items, failure: null);
  }

  @override
  Future<({List<Detection> detections, Failure? failure})>
  getPendingDetections() async {
    return (detections: items, failure: null);
  }

  @override
  Future<({Detection? detection, Failure? failure})> saveDetection(
    Detection detection, {
    required String userEmail,
    required String userName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<({int synced, Failure? failure})> markSynced({
    required String code,
    required DateTime syncedAt,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('GetDetections meneruskan daftar dari repository', () async {
    final repository = FakeDetectionRepository(
      items: <Detection>[
        Detection(
          code: 'H-001',
          plantCode: 'TMT-001',
          plantName: 'Tomat Pot Depan',
          accuracy: 96,
          isHealthy: true,
          inspectedAt: DateTime(2026, 9, 28),
        ),
      ],
    );

    final result = await GetDetections(repository).call();

    expect(result.failure, isNull);
    expect(result.detections, hasLength(1));
    expect(result.detections.first.code, 'H-001');
  });

  test('GetDetections meneruskan failure tanpa melempar', () async {
    final repository = FakeDetectionRepository(fail: true);

    final result = await GetDetections(repository).call();

    expect(result.failure, isA<LocalFailure>());
    expect(result.detections, isEmpty);
  });
}