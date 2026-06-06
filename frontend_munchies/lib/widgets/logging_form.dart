//this is the default tracking page

// ignore_for_file: non_constant_identifier_names


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/services/auth_exception.dart';
import 'package:frontend_munchies/services/record_services.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/image_widgets.dart/image_selection_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_munchies/models/record.dart';

enum Categories {
  pastry,
  beverages,
  cakes,
  confectionery,
  frozen,
  fruits,
  healthier,
  none,
}

class LoggingForm extends StatefulWidget {
  const LoggingForm({super.key});

  @override
  State<LoggingForm> createState() => _LoggingFormState();
}

class _LoggingFormState extends State<LoggingForm> with RouteAware {
  DateTime? _selectedDate;
  TextEditingController itemNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  String? _imageField;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isFavourited = false;
  String? _errorMessage;

  // ignore: unused_field
  Categories? _selectedCategory;
  final inputTextStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colours.darkBrown,
  );
  final backgroundTextStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colours.darkBrown.withValues(alpha: 0.45),
  );
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _selectedDate ?? DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        String month = date.month >= 10 ? "${date.month}" : "0${date.month}";
        String day = date.day >= 10 ? "${date.day}" : "0${date.day}";
        dateController.text = "${date.year}-$month-$day";
      });
    }
  }

  InputDecoration basicBoxDeco(String labelText) {
    return InputDecoration(
      filled: true,
      fillColor: Colours.lightBeige,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colours.greyPink),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colours.greyPink),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      labelText: labelText,
      labelStyle: backgroundTextStyle,
      errorStyle: GoogleFonts.poppins(color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    var optionalInputdecorationtheme = InputDecorationTheme(
      filled: true,
      fillColor: Colours.lightBeige,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.brown.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.brown.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
    );

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: ScrollConfiguration(
            behavior: ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 25.0,
                    bottom: 35.0,
                    right: 14.0,
                    left: 14.0,
                  ),
                  child: Column(
                    spacing: 12.0,
                    children: [
                      //ITEMNAME FIELD
                      _buildItemNameField(basicBoxDeco),
                      //DATE ROW
                      _buildDateField(basicBoxDeco),
                      //COST ROW
                      _buildCostField(basicBoxDeco),
                      //OTHER DETAILS BEGIN
                      _buildOthersRow(),
                      //DETAILS
                      _buildDetailsField(optionalInputdecorationtheme),
                      //CATEGORY
                      _buildCatDropdown(
                        constraints,
                        optionalInputdecorationtheme,
                      ),
                      ImageSelectionButton(
                        backgroundTextStyle: backgroundTextStyle,
                        sendBack64: (base64) => setState(() {
                          _imageField = base64;
                        }),
                      ),
                      _buildActionRow(width, height),
                      _showErrorMessage(_errorMessage),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Center _showErrorMessage(String? errorMessage) {
    if (errorMessage == null) {
      return Center();
    } else if (errorMessage.isEmpty) {
      return Center();
    } else {
      return Center(
        child: Text(
          errorMessage,
          style: GoogleFonts.poppins(color: Colors.red, fontSize: 14.0),
        ),
      );
    }
  }

  Row _buildCostField(InputDecoration Function(String labelText) basicBoxDeco) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Cost (\$)    ',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xff795A52),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: costController,
            style: inputTextStyle,
            decoration: basicBoxDeco('How much did you spend?'),
            validator: (value) => ((value == null || value.isEmpty)
                ? "Field cannot be empty"
                : null),
          ),
        ),
      ],
    );
  }

  Row _buildActionRow(double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () async {
            var success = _formKey.currentState!.validate();
            if (success) {
              AsyncSnapshot.waiting();
              _saveRecord();
              Navigator.of(context).pop();
            }
          },

          style: OutlinedButton.styleFrom(
            backgroundColor: Colours.greyPink,
            fixedSize: Size(width * 0.75, 53),
            side: BorderSide(color: Colours.greyPink),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Save',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0),
          ),
        ),
        IconButton(
          //ADD FAVOURITING HERE
          onPressed: () {
            setState(() {
              _isFavourited = !_isFavourited;
            });
          },
          icon: Icon(
            _isFavourited
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isFavourited ? Colours.lightPink : Color(0xffA98379),
            size: 53,
          ),
        ),
      ],
    );
  }

  Future<void> _saveRecord() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String idToken = await user.getIdToken() ?? '';
        if (idToken == '') {
          throw AuthException('No permission to access this page.');
        }
        Record rec = Record(
          user_uid: user.uid,
          itemName: itemNameController.text,
          date: DateTime.parse(dateController.text),
          cost: (double.parse(costController.text) * 100).toInt(),
          photo: _imageField,
          isFavourited: _isFavourited,
        );
        await RecordServices.createRecord(idToken, rec);

        if (!mounted) return;
        //change _errorMessage to be nothing on success
        setState(() {
          _errorMessage = null;
        });
      } else {
        throw AuthException('No permission to access this page.');
      }
    } on FormatException {
      setState(() {
        _errorMessage =
            "Remember: use date picker for Date and key in a valid value for cost";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Unexpected error. Please try again later. ";
      });
    }
  }

  DropdownMenu<Categories> _buildCatDropdown(
    BoxConstraints constraints,
    InputDecorationTheme optionalInputdecorationtheme,
  ) {
    return DropdownMenu<Categories>(
      trailingIcon: Icon(
        Icons.arrow_drop_down_rounded,
        color: Colours.darkBrown,
      ),
      selectedTrailingIcon: Icon(
        Icons.arrow_drop_up_rounded,
        color: Colours.darkBrown,
      ),
      menuHeight: 150,
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Colours.darkerBeige),
      ),
      width: constraints.maxWidth,
      inputDecorationTheme: optionalInputdecorationtheme,
      onSelected: (Categories? cat) {
        setState(() {
          _selectedCategory = cat;
        });
      },
      controller: categoryController,
      enableFilter: true,
      requestFocusOnTap: true,
      leadingIcon: const Icon(Icons.category_rounded, color: Colours.darkBrown),
      label: Text(
        "Add a category label",
        textAlign: TextAlign.center,
        style: backgroundTextStyle,
      ),
      dropdownMenuEntries: [
        DropdownMenuEntry(label: 'beverages', value: Categories.beverages),
        DropdownMenuEntry(label: 'cakes', value: Categories.cakes),
        DropdownMenuEntry(
          label: 'confectionery',
          value: Categories.confectionery,
        ),
        DropdownMenuEntry(label: 'frozen', value: Categories.frozen),
        DropdownMenuEntry(label: 'fruits', value: Categories.fruits),
        DropdownMenuEntry(label: 'healthier', value: Categories.healthier),
        DropdownMenuEntry(label: 'pastry', value: Categories.pastry),
      ],
    );
  }

  TextFormField _buildDetailsField(
    InputDecorationTheme optionalInputdecorationtheme,
  ) {
    return TextFormField(
      style: inputTextStyle,
      controller: detailsController,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: backgroundTextStyle,
      ).applyDefaults(optionalInputdecorationtheme),
    );
  }

  Row _buildOthersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 17.0, bottom: 0.0),
          child: Text(
            "OTHERS",
            style: TextStyle(
              fontFamily: 'Cherry_Bomb_One',
              color: Colours.darkBrown,
              fontSize: 26,
            ),
          ),
        ),
      ],
    );
  }

  Row _buildDateField(InputDecoration Function(String labelText) basicBoxDeco) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Date           ',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xff795A52),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: dateController,
            style: inputTextStyle,
            readOnly: true,
            onTap: () => _selectDate(),
            decoration: basicBoxDeco('Click to enter date!'),
            validator: (value) => ((value == null || value.isEmpty)
                ? "Field cannot be empty"
                : null),
          ),
        ),
      ],
    );
  }

  Row _buildItemNameField(
    InputDecoration Function(String labelText) basicBoxDeco,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "munched",
          style: TextStyle(
            fontFamily: 'Cherry_Bomb_One',
            fontSize: 24,
            color: Colours.greyPink,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: itemNameController,
            style: inputTextStyle,
            decoration: basicBoxDeco('What did you have?'),
            validator: (value) => ((value == null || value.isEmpty)
                ? "Field cannot be empty"
                : null),
          ),
        ),
      ],
    );
  }
}
