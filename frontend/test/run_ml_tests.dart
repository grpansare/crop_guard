import 'dart:io';

void main(List<String> arguments) async {
  print('🧪 ML Model Test Runner');
  print('======================\n');

  if (arguments.isEmpty) {
    printUsage();
    return;
  }

  final command = arguments[0].toLowerCase();

  switch (command) {
    case 'quick':
      await runQuickTest();
      break;
    case 'comprehensive':
      await runComprehensiveTest();
      break;
    case 'performance':
      await runPerformanceTest();
      break;
    case 'all':
      await runAllTests();
      break;
    default:
      print('❌ Unknown command: $command');
      printUsage();
  }
}

void printUsage() {
  print('Usage: dart test/run_ml_tests.dart <command>');
  print('');
  print('Commands:');
  print('  quick         - Run basic ML service tests');
  print('  comprehensive - Run comprehensive test suite');
  print('  performance   - Run performance benchmarks');
  print('  all          - Run all tests');
  print('');
  print('Examples:');
  print('  dart test/run_ml_tests.dart quick');
  print('  dart test/run_ml_tests.dart comprehensive');
}

Future<void> runQuickTest() async {
  print('🚀 Running Quick ML Tests...\n');
  
  final result = await Process.run(
    'flutter',
    ['test', 'test/ml_service_working_test.dart', '--verbose'],
    workingDirectory: '.',
  );
  
  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print('Errors:');
    print(result.stderr);
  }
  
  if (result.exitCode == 0) {
    print('✅ Quick tests completed successfully!');
  } else {
    print('❌ Quick tests failed with exit code: ${result.exitCode}');
  }
}

Future<void> runComprehensiveTest() async {
  print('🔬 Running Comprehensive ML Tests...\n');
  
  final result = await Process.run(
    'flutter',
    ['test', 'test/comprehensive_ml_test.dart', '--verbose'],
    workingDirectory: '.',
  );
  
  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print('Errors:');
    print(result.stderr);
  }
  
  if (result.exitCode == 0) {
    print('✅ Comprehensive tests completed successfully!');
  } else {
    print('❌ Comprehensive tests failed with exit code: ${result.exitCode}');
  }
}

Future<void> runPerformanceTest() async {
  print('⏱️ Running Performance Tests...\n');
  
  final result = await Process.run(
    'flutter',
    ['test', 'test/comprehensive_ml_test.dart', '--verbose', '--name', 'performance'],
    workingDirectory: '.',
  );
  
  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print('Errors:');
    print(result.stderr);
  }
  
  if (result.exitCode == 0) {
    print('✅ Performance tests completed successfully!');
  } else {
    print('❌ Performance tests failed with exit code: ${result.exitCode}');
  }
}

Future<void> runAllTests() async {
  print('🎯 Running All ML Tests...\n');
  
  await runQuickTest();
  print('\n' + '='*50 + '\n');
  await runComprehensiveTest();
  
  print('\n🎉 All tests completed!');
}
