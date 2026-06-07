// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:frontend_munchies/screens/viewOptions_Track/tracking.dart';
import 'package:frontend_munchies/services/records/record_changer.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/widgets/logging_widgets/logging_form.dart';
import 'package:provider/provider.dart';



class UpdateButton extends StatelessWidget {
  final String recordId;

  const UpdateButton({super.key, required this.recordId});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        Record rec = await Provider.of<RecordChanger>(context, listen: false).getRecord(recordId);
        if (!context.mounted) return;
        Navigator.push(
          context,
          //tracking page takes in an optional logging form. if logging form exists, use as child, else create new one
          MaterialPageRoute(
            builder: (context) => TrackingPage(loggingForm: LoggingForm(record: rec,)),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Icon(Icons.edit, size: 32, color: Colours.greyPink),
          Text(
            'Edit',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colours.darkBrown,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  // Future<Record> getRecord() async {
  //   try {
  //     User? usr = FirebaseAuth.instance.currentUser;
  //     if (usr == null) throw AuthException('No permission to access.');
  //     String? idToken = await usr.getIdToken(true);
  //     if (idToken == null || idToken.isEmpty) {
  //       throw AuthException('No permission to access. ');
  //     }
  //     return RecordServices.getRecord(idToken, recordId);
  //   } catch (e) {
  //     throw Exception(e.toString());
  //   }
  // }



  //   try {
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       String idToken = await user.getIdToken() ?? '';
  //       if (idToken == '') {
  //         throw AuthException('No permission to access this page.');
  //       }
  //       Record rec = Record(
  //         record_id: recordId,
  //         user_uid: user.uid,
  //         itemName: itemNameController.text,
  //         date: DateTime.parse(dateController.text),
  //         cost: (double.parse(costController.text) * 100).toInt(),
  //         photo: _imageField,
  //         isFavourited: _isFavourited,
  //       );
  //       await RecordServices.createRecord(idToken, rec);

  //       if (!mounted) return;
  //       //change _errorMessage to be nothing on success
  //       setState(() {
  //         _errorMessage = null;
  //       });
  //     } else {
  //       throw AuthException('No permission to access this page.');
  //     }
  //   } on FormatException {
  //     setState(() {
  //       _errorMessage =
  //           "Remember: use date picker for Date and key in a valid value for cost";
  //     });
  //   } catch (e) {
  //     if (!mounted) return;
  //     setState(() {
  //       _errorMessage = "Unexpected error. Please try again later. ";
  //     });
  //   }
  // }
}
