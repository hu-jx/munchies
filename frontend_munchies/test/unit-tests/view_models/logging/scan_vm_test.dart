//TEST ONLY THE CRUCIAL BUSINESS LOGIC
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/screens/loggingFeature/repository/scan_repository.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/scan_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockScanRepo extends Mock implements ScanRepository {}
class MockFile extends Mock implements File {}
void main() {
  //Since scanPicture wraps the HTTP call and requires an actual FirebaseAuth session on success, it is not tested in VM unit tests
  late MockScanRepo mockScanRepo;
  late ScanViewModel scanViewModel;
  late MockFile mockFile;
  setUp(() {
    mockScanRepo = MockScanRepo();
    scanViewModel = ScanViewModel(scanRepo: mockScanRepo);
    mockFile = MockFile();
    Uint8List mockBytes =Uint8List.fromList([0xFF, 0xD8, 0xFF]);
    when(() => mockFile.readAsBytesSync()).thenReturn(mockBytes);
    when(() => mockFile.path).thenReturn('image/jpeg');
  });
  group('onScanPressed', () {
    test('On success', () async {
      String? param;
      when(() => mockScanRepo.scanPicture(any<String>()),).thenAnswer((inv) async {
        param = inv.positionalArguments[0];
        param ??= 'null';
        return param!;
      });
      scanViewModel.setPhotoFile(mockFile);

      await scanViewModel.onScanPressed();

      expect(scanViewModel.itemName, isNot('null'));
      expect(scanViewModel.itemName, param);
      expect(scanViewModel.itemName, isNot(null));
      expect(scanViewModel.errorMessage, null);
      expect(scanViewModel.isLoading, false);
      verify(() => mockScanRepo.scanPicture(any<String>()),).called(1);
    });
    group('On failure', () {
      test('If no photo file is found, set new error message', () async {
        final future = scanViewModel.onScanPressed();
        expect(scanViewModel.isLoading, false);

        await future;
        expect(scanViewModel.errorMessage, 'No image present for scanning. Add a photo and try again.');
        expect(scanViewModel.isLoading, false);
      });
    test(
      'Handles errors when a wrong file type is handed BEFORE hitting server instead of having indefinite loading ',
      () {
        final corruptedFile = MockFile();
        when(() => corruptedFile.path).thenReturn('application/pdf');
        when(() => corruptedFile.readAsBytesSync()).thenReturn(Uint8List.fromList([37, 80, 68, 70, 45, 49, 46, 52]));
        scanViewModel.setPhotoFile(corruptedFile);
        scanViewModel.onScanPressed();
        expect(scanViewModel.errorMessage, 'Exception: File is unsupported or corrupted.');
      },
    );
    test(
      'Handles errors when an empty file is handed BEFORE hitting server instead of having indefinite loading ',
      () async {
        final corruptedFile = MockFile();
        when(() => corruptedFile.readAsBytesSync()).thenReturn(Uint8List(0));
        scanViewModel.setPhotoFile(corruptedFile);
        await scanViewModel.onScanPressed();
        expect(scanViewModel.errorMessage, 'Exception: File is unsupported or corrupted.');
      },
    );
    test(
      'Handles errors if one is caught during stages further down the scanning pipeline (e.g. API Error even after retries)',
      () {
        when(() => mockScanRepo.scanPicture(any<String>())).thenThrow(Exception('Test error'));
        scanViewModel.setPhotoFile(mockFile);

        scanViewModel.setPhotoFile(mockFile);
        scanViewModel.onScanPressed();
        expect(scanViewModel.errorMessage, 'Exception: Test error');
      },
    );
    });
  });
}
