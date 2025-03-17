import 'dart:async';
import 'dart:io';

import 'package:hive_storage_benchmark/bench_result.dart';
import 'package:hive_storage_benchmark/db_type.dart';
import 'package:hive_storage_benchmark/test_model.dart';

const _boxName = 'test_box';
const _model = TestModel(
  testModelFieldZero: 0,
  testModelFieldOne: 1,
  testModelFieldTwo: 2,
  testModelFieldThree: 3,
  testModelFieldFour: 4,
  testModelFieldFive: 5,
  testModelFieldSix: 6,
  testModelFieldSeven: 7,
  testModelFieldEight: 8,
  testModelFieldNine: 9,
);
const _passes = 5;

Future<BenchResult> runBenchmark({
  required String name,
  required int operations,
  required DbType type,
  required FutureOr<dynamic> Function(String name) openBox,
}) async {
  final boxFile = File(type.boxFileName(_boxName));

  var totalTime = Duration.zero;
  for (var run = 1; run <= _passes; run++) {
    print('\nRunning $operations operation $name benchmark pass $run...');

    boxFile.deleteSync();
    final box = await openBox(_boxName);

    final stopwatch = Stopwatch()..start();
    for (var i = 0; i < operations; i++) {
      if (i % 10000 == 0) {
        print('Operation: $i');
      }
      await box.add(_model);
    }
    final elapsed = stopwatch.elapsed;
    totalTime += elapsed;

    await box.close();

    print('Time: $elapsed');
  }

  final avgTime = Duration(microseconds: totalTime.inMicroseconds ~/ _passes);

  final size = boxFile.lengthSync();
  final megabytes = size / 1024 / 1024;
  final megabytesString = megabytes.toStringAsFixed(2);

  print('\nAverage Results:');
  print('Time: $avgTime');
  print('Size: $megabytesString MB');

  return BenchResult(time: avgTime, size: megabytes);
}
