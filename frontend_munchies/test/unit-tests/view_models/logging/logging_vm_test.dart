import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_munchies/models/category_item.dart';
import 'package:frontend_munchies/screens/activities/domain/repositories/record_repo.dart';
import 'package:frontend_munchies/screens/loggingFeature/view_models/logging_view_model.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:mocktail/mocktail.dart';

class MockRecordRepo extends Mock implements RecordRepository {}

class MockFile extends Mock implements File {}

void main() {
  late MockRecordRepo mockRepo;
  late Record toUpdate;
  late Record toSave;

  setUpAll(() {
    registerFallbackValue(
      Record(
        itemName: 'toSave',
        date: DateTime.now(),
        cost: 500,
        isFavourited: false,
        isVisible: false,
      ),
    );
  });

  setUp(() {
    mockRepo = MockRecordRepo();
    toUpdate = Record(
      record_id: 'id',
      itemName: 'toUpdate',
      date: DateTime.now(),
      cost: 500,
      isFavourited: false,
      isVisible: false,
    );
    toSave = Record(
      itemName: 'toSave',
      date: DateTime.now(),
      cost: 500,
      isFavourited: false,
      isVisible: false,
    );
  });

  group('State setter checks', () {
    late LoggingViewModel viewModel;
    setUp(() {
      viewModel = LoggingViewModel(recordChanger: mockRepo);
    });
    group(
      'Loading state checks - loading boolean changes and listeners are notified',
      () {
        test('onloading turns loading on and notifies listeners', () {
          var notified = false;
          viewModel.addListener(() => notified = true);
          viewModel.onLoading();
          expect(viewModel.isLoading, true);
          expect(notified, true);
        });

        test('offLoading turns loading off and notifies listeners', () {
          var notified = false;
          viewModel.addListener(() => notified = true);
          viewModel.offLoading();
          expect(viewModel.isLoading, false);
          expect(notified, true);
        });
      },
    );

    //since all field setters are modelled in the same way, we will only check for one.
    test(
      'Field state checks - state of field value changes without notifying listeners for TextFormFields',
      () {
        var notified = false;
        viewModel.addListener(() => notified = true);
        viewModel.setItemName('itemName');
        expect(viewModel.itemName, 'itemName');
        expect(notified, false);
      },
    );

    test(
      'Field value updates with listeners notified for fields involving picking (e.g. dateField, boolean fields, category)',
      () {
        var notified = false;
        CategoryItem fakeCategory = CategoryItem(
          labelText: 'Fake Category',
          name: 'fakeCategory',
        );
        viewModel.addListener(() => notified = true);
        viewModel.setCat(fakeCategory);
        expect(viewModel.category, fakeCategory.labelText);
        expect(notified, true);
      },
    );

    test(
      'white spaces are deleted for fields requiring further parsing (Cost)',
      () {
        var costWithWhiteSpace = '  4.80  ';
        viewModel.setCost(costWithWhiteSpace);
        expect(viewModel.cost, '4.80');
      },
    );
  });

  group('Validator checks', () {
    test(
      'required field validators ensure that a non-null value is returned when empty',
      () {
        String emptyString = '';

        String? emptyStringResult = LoggingViewModel.requiredValidator(
          emptyString,
        );
        String? nullValueResult = LoggingViewModel.requiredValidator(null);
        String? validValue = LoggingViewModel.requiredValidator('valid');
        expect({emptyStringResult, nullValueResult}, {'Field cannot be empty'});
        expect(validValue, null);
      },
    );
    test(
      'cost validator returns non-null value if an invalid cost value is given',
      () {
        String invalidCostValue = 'xxx';
        String validCostValue = '4.8';
        String? invalidCostResult = LoggingViewModel.costValidator(
          invalidCostValue,
        );
        String? validCostResult = LoggingViewModel.costValidator(
          validCostValue,
        );

        expect(invalidCostResult, 'Invalid value for cost.');
        expect(validCostResult, null);
      },
    );
  });

  group(
    'checkIfUpdate returns either updated value or the clean empty state value',
    () {
      test('Always return the new value if new value is present', () {
        var resultWithOriginal = LoggingViewModel.checkIfUpdate(true, 'new');
        var resultWithoutOriginal = LoggingViewModel.checkIfUpdate(null, 'new');
        expect(resultWithOriginal, 'new');
        expect(resultWithoutOriginal, 'new');
      });
      test(
        'Returns old value if original value is present and there is no new value',
        () {
          var resultWithoutNew = LoggingViewModel.checkIfUpdate(
            'original',
            null,
          );
          expect(resultWithoutNew, 'original');
        },
      );
      test('Null returned if both new and old fields are null', () {
        var result = LoggingViewModel.checkIfUpdate(null, null);
        expect(result, null);
      });
    },
  );

  group('onSavePressed', () {
    late LoggingViewModel viewModel;
    late List<String> logs;
    setUp(() {
      viewModel = LoggingViewModel(recordChanger: mockRepo);
      logs = [];
      debugPrint = (printable, {int? wrapWidth}) {
        logs.add(printable.toString());
      };
    });
    test('Initial state - loading turned off and error message is null', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });
    test(
      'goes to saveRecord if there is no record_id in the Record instance',
      () async {
        LoggingViewModel saveViewModel = LoggingViewModel(
          recordChanger: mockRepo,
          record: toSave,
        );

        when(
          () => mockRepo.saveRecord(any()),
        ).thenAnswer((_) async => debugPrint('save record'));
        when(
          () => mockRepo.patchRecord(toUpdate.record_id!, {}),
        ).thenAnswer((_) async => debugPrint('update record'));
        await saveViewModel.onSavePressed();

        expect(logs.length, 1);
        expect(logs, ['save record']);
        verify(() => mockRepo.saveRecord(any())).called(1);
        verifyNever(() => mockRepo.patchRecord(toUpdate.record_id!, {}));

        //loading and error states back to normal
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
      },
    );

    test(
      'goes to updateRecord if there is a record_id in the Record instance',
      () async {
        //constructed dynamically in updateRecord()
        Map<String, dynamic> updates = {
          'itemName': 'new',
          'date': null,
          'cost': null,
          'photo_file': null,
          'category': null,
          'isFavourited': null,
          'details': null,
          'isVisible': null,
        };
        LoggingViewModel updateViewModel = LoggingViewModel(
          recordChanger: mockRepo,
          record: toUpdate,
        );
        updateViewModel.setItemName('new');
        when(
          () => mockRepo.saveRecord(any()),
        ).thenAnswer((_) async => debugPrint('save record'));
        when(
          () => mockRepo.patchRecord('id', updates),
        ).thenAnswer((_) async => debugPrint('update record'));
        await updateViewModel.onSavePressed();

        expect(logs.length, 1);
        expect(logs, ['update record']);
        verifyNever(() => mockRepo.saveRecord(any()));
        verify(
          () => mockRepo.patchRecord(toUpdate.record_id!, updates),
        ).called(1);

        //loading and error states back to normal
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, null);
      },
    );
    test(
      'Duplicated calls are prevented if onSavePressed is triggered again',
      () async {
        LoggingViewModel saveViewModel = LoggingViewModel(
          recordChanger: mockRepo,
          record: toSave,
        );

        when(
          () => mockRepo.saveRecord(any()),
        ).thenAnswer((_) async => debugPrint('save record'));

        //first save call
        saveViewModel.onSavePressed();
        //expect that loading status changes
        expect(saveViewModel.isLoading, true);

        //second save call
        saveViewModel.onSavePressed();

        //third save call
        saveViewModel.onSavePressed();

        //complete all events
        await pumpEventQueue();
        //expect that saveRecord was only called once although .onSavePressed() called twice
        verify(() => mockRepo.saveRecord(any())).called(1);
        expect(logs, ['save record']);
        expect(saveViewModel.errorMessage, null);
        expect(saveViewModel.isLoading, false);
      },
    );
  });

  group('saveRecord', () {
    late LoggingViewModel vm;
    late File mockPhotoFile;
    late bool notified;
    setUp(() {
      vm = LoggingViewModel(recordChanger: mockRepo);
      mockPhotoFile = MockFile();

      //set up VM for a Manual record
      vm.setItemName('mockRec');
      vm.setCost('5');
      vm.setDate(DateTime(2026, 6, 1));
      vm.setVisibility(false);
      vm.setNotFav();
      vm.setCat(CategoryItem(name: 'MockCat', labelText: 'mockCat'));
      vm.setDetails('MockDetails');
      vm.setPhotoFile(mockPhotoFile);

      //check for notifyListeners() functionalities
      notified = false;
      vm.addListener(() => notified = true);
    });
    test(
      'Check that initial state is set up properly - no loading, correct field values and no error messages',
      () {
        expect(vm.itemName, 'mockRec');
        expect(vm.cost, '5');
        expect(vm.date, DateTime(2026, 6, 1));
        expect(vm.isVisible, false);
        expect(vm.isFavourited, false);
        expect(vm.isLoading, false);
        expect(vm.errorMessage, null);
        expect(vm.existing_file, mockPhotoFile);
        expect(vm.details, 'MockDetails');
      },
    );

    test('On success', () {
      Record? paramRecord;

      //check that the record received by saveRecord is of the correct values and shapes.
      when(() => mockRepo.saveRecord(any<Record>())).thenAnswer((rec) async {
        paramRecord = rec.positionalArguments[0];
      });
      vm.saveRecord();

      expect(paramRecord?.itemName, vm.itemName);
      expect(vm.cost == null, false);
      expect(paramRecord?.cost, (double.parse(vm.cost!) * 100).toInt());
      expect(paramRecord?.date, vm.date);
      expect(paramRecord?.isFavourited, vm.isFavourited);
      expect(paramRecord?.isVisible, vm.isVisible);
      expect(paramRecord?.photo_file, vm.existing_file);
      expect(paramRecord?.details, vm.details);

      //check the number of calls
      verify(() => mockRepo.saveRecord(any<Record>())).called(1);
      verifyNever(() => mockRepo.patchRecord(any(), any()));
    });
    group('SaveRecord throws errors on failure and does not crash UI', () {
      test(
        'If there are null values on required fields, error message is updated and record is not saved',
        () {
          //intentionally have required fields to be null by instantiating a new VM
          LoggingViewModel vmWithNoValues = LoggingViewModel(
            recordChanger: mockRepo,
          );
          vmWithNoValues.saveRecord();
          when(
            () => mockRepo.saveRecord(any<Record>()),
          ).thenAnswer((rec) async {});

          //expect that errorMessage is updated with a FormatException message
          expect(vmWithNoValues.errorMessage, isNot(null));
          expect(
            vmWithNoValues.errorMessage,
            LoggingViewModel.invalidFormatErrorMessage,
          );

          //expect that .saveRecord is never called
          verifyNever(() => mockRepo.saveRecord(any<Record>()));
        },
      );

      test(
        'If there are values of invalid format, error message is updated and record is not saved',
        () {
          vm.setCost('xxx');
          when(
            () => mockRepo.saveRecord(any<Record>()),
          ).thenAnswer((rec) async {});
          vm.saveRecord();

          //since error message update triggers an UI update - check that listeners are notified.
          expect(vm.errorMessage, LoggingViewModel.invalidFormatErrorMessage);
          expect(notified, true);
          verifyNever(() => mockRepo.saveRecord(any<Record>()));
        },
      );
      test(
        'If error occurs when saving record, record is not saved, error message is updated and listeners are notified.',
        () {
          when(
            () => mockRepo.saveRecord(any<Record>()),
          ).thenThrow(Exception('Test Exception'));
          vm.saveRecord();

          expect(vm.errorMessage, 'Exception: Test Exception');
          expect(notified, true);

          //.saveRecord is called once and throws an error.
          verify(() => mockRepo.saveRecord(any<Record>())).called(1);
        },
      );
    });
  });

  group('patchRecord', () {
    late LoggingViewModel updateViewModel;
    late Map<String, dynamic> cleanStateUpdates;
    late Map<String, dynamic> modifiedUpdates;
    setUp(() {
      updateViewModel = LoggingViewModel(
        recordChanger: mockRepo,
        record: toUpdate,
      );
      cleanStateUpdates = {
        'itemName': null,
        'date': null,
        'cost': null,
        'photo_file': null,
        'category': null,
        'isFavourited': null,
        'details': null,
        'isVisible': null,
      };
      modifiedUpdates = Map.from(cleanStateUpdates).map(
      (key, value) => key == 'itemName'
          ? MapEntry(key, 'updatedValue')
          : MapEntry(key, value),
    );
    });
    
  
    test('Success case: Update values take the most recent one at point of updating', () async {
      Map<String, dynamic>? paramUpdates;
      int counter = 0;
      updateViewModel.addListener(() => counter++);
      updateViewModel.setItemName('updatedValue');
      when(() => mockRepo.patchRecord(any<String>(), any())).thenAnswer((
        inv,
      ) async {
        paramUpdates = inv.positionalArguments[1];
      });

      await updateViewModel.patchRecord();

      //no loading involved at patching. only notify if there is error message
      expect(counter, 0);
      expect(paramUpdates, modifiedUpdates);
      verify(() => mockRepo.patchRecord(any<String>(), any<Map<String, dynamic>>())).called(1);
    });

    test('If there is nothing to update, operation ceases immediately and notifies listeners', () async {
      int counter = 0;
      when(() => mockRepo.patchRecord('id', any())).thenAnswer((_) async {});
      updateViewModel.addListener(() => counter++,);
      updateViewModel.onSavePressed();
      await pumpEventQueue();

      expect(counter, 2);
      //stop loading once this happens 
      expect(updateViewModel.isLoading, false);
      //expect that the pipeline never gets to actual RecordRepoImpl (to prevent unnecessary rebuilds due to stream)
      verifyNever(() => mockRepo.patchRecord(any<String>(), any<Map<String, dynamic>>()));
    });

    group('Errors on patchRecord', () {
      test('if no record is linked, action fails', () {
        LoggingViewModel noRecordPatchVM = LoggingViewModel(recordChanger: mockRepo);
        noRecordPatchVM.patchRecord();
        expect(noRecordPatchVM.errorMessage, 'Exception: No record id linked to edit.');
        expect(noRecordPatchVM.isLoading, false);
      });
      test('On failure, error message updates with notif and no record is saved.', () {
        int numNotif = 0;
        when(() => mockRepo.patchRecord(any(), any()),).thenThrow(Exception('Test Exception'));
        //add listener to check for final notified status

        //make an update so that recordrepo's methods are triggered
        updateViewModel.setAsFav();
        updateViewModel.addListener(() => numNotif++);
        updateViewModel.patchRecord();

        //assert
        expect(updateViewModel.errorMessage, 'Exception: Test Exception');
        expect(updateViewModel.isLoading, false);

        //3 notif from update solely (onLoad, update error, offLoad), 1 from setting state
        expect(numNotif, 1);
      });
    });
  });

  group('disposal', () {
    late LoggingViewModel viewModel;
    setUp(() {
      viewModel = LoggingViewModel(recordChanger: mockRepo, record: toSave);
    });

    //FIXME: ISSUE IDENTIFIED - LoggingForm(onSavePressed): cancelable operation
    // test(
    //   'VM no longer referenced such as via notifying listeners after disposal',
    //   () async {
    //   int counter = 0;
    //   viewModel.addListener(() => counter++);
    //   int beforeDisposalNotifCounter = counter;
      
    //   final Future future = viewModel.onSavePressed();
    //   viewModel.dispose();
      
    //   //after disposal, no more notifying happens and functions do not execute anymore
    //   //number of notifyListeners() called == 3 due to setting up toSave record instance
    //   expect(counter, beforeDisposalNotifCounter);
    //   expect(counter, 3);
    //   expect(() async => await future, returnsNormally);
    //   verifyNever(() => mockRepo.saveRecord(any()),);
    //   },
    // );

    // test('VM no longer referenced after disposal even if recordRepo method has started running',() async {
    //   Record? param;
    //   when(() => mockRepo.saveRecord(any()),).thenAnswer((inv) async {
    //     param = inv.positionalArguments[0];
    //   });

    //   int counter = 0;
    //   viewModel.addListener(() => counter++);
      
    //   viewModel.saveRecord();
    //   int beforeDisposalNotifCounter = counter;
    //   viewModel.dispose();
    //   await pumpEventQueue();


    //   // expect(param, toSave);
    //   verify(() => mockRepo.saveRecord(any()),).called(1);
    //   expect(beforeDisposalNotifCounter, counter);

    //   expect(counter, 1);
    //   expect(param, toSave);
    // });
  });
}
