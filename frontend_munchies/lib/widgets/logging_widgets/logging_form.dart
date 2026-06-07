//this is the default tracking page

// ignore_for_file: non_constant_identifier_names

import 'dart:core';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/category_item.dart';
import 'package:frontend_munchies/services/records/record_changer.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:frontend_munchies/widgets/image_widgets.dart/image_selection_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_munchies/models/record.dart';
import 'package:provider/provider.dart';

class LoggingForm extends StatefulWidget {
  final Record? record;

  const LoggingForm({super.key, this.record});

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
  final RecordChanger recChange = RecordChanger();
  String? _imageField;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isFavourited = false;
  String? _errorMessage;
  CategoryItem? _selectedCategory;
  final Map<String, dynamic> _updates = {
    'itemName': null,
    'date': null,
    'cost': null,
    'photo': null,
    'category': null,
    'isFavourited': null,
    'details': null,
  };

  final List<CategoryItem> categories =
      [
        'pastry',
        'cakes',
        'confectionery',
        'frozen',
        'fruits',
        'healthier',
        'beverages',
      ].map((stringCat) {
        return CategoryItem(
          name: stringCat,
          labelText: "${stringCat[0].toUpperCase()}${stringCat.substring(1)}",
        );
      }).toList();
  late bool _originalFav;
  late String? _originalBase64;
  late String? _originalCategory;
  String? itemName;
  String? cost;
  String? details;
  RecordChanger? _recordChanger;

  //TODO: MOVE TO STYLES
  final inputTextStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colours.darkBrown,
  );
  final backgroundTextStyle = TextStyle(
    fontFamily: 'Poppins',
    color: Colours.darkBrown.withValues(alpha: 0.45),
  );

  String formatDate(DateTime date) {
    String month = date.month >= 10 ? "${date.month}" : "0${date.month}";
    String day = date.day >= 10 ? "${date.day}" : "0${date.day}";
    return "${date.year}-$month-$day";
  }

  void checkIfUpdate() {
    if (widget.record != null) {
      _originalFav = widget.record!.isFavourited;
      _selectedDate = widget.record!.date;
      dateController.text = formatDate(_selectedDate!);
      if (widget.record?.record_id != null) {
        setState(() {
          _isFavourited = _originalFav;
          _originalBase64 = widget.record!.photo;
          _originalCategory = widget.record!.category;
          if (_originalBase64 != null) _imageField = _originalBase64;
          itemNameController.text = widget.record!.itemName;
          costController.text = (widget.record!.cost / 100).toStringAsFixed(2);
          if (widget.record!.details != null) {
            detailsController.text = widget.record!.details!;
          }
          if (_originalCategory != null) {
            _selectedCategory = categories.firstWhere(
              (str) => str.labelText == _originalCategory,
              orElse: () => CategoryItem(
                name: _originalCategory!,
                labelText: _originalCategory!,
              ),
            );
          }
        });
        debugPrint('I am at check if update $_originalBase64');
      } else if (widget.record != null && widget.record?.record_id == null) {
        //saving with favourite
        setState(() {
          itemNameController.text = widget.record!.itemName;
          costController.text = (widget.record!.cost / 100).toStringAsFixed(2);
          _isFavourited = _originalFav;
        });

      }
    }
  }

  //TODO: MOVE TO STYLES
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recordChanger = context.read<RecordChanger>();
  }

  @override
  void initState() {
    super.initState();
    checkIfUpdate();

    if (widget.record != null) {
      itemNameController.addListener(() {
        _updates['itemName'] =
            itemNameController.text != widget.record!.itemName
            ? itemNameController.text
            : null;
      });

      dateController.addListener(() {
        _updates['date'] =
            dateController.text !=
                widget.record!.date.toIso8601String().split('T')[0]
            ? dateController.text
            : null;
      });
      costController.addListener(() {
        _updates['cost'] =
            costController.text !=
                (widget.record!.cost / 100).toStringAsFixed(2)
            ? costController.text
            : null;
      });

      detailsController.addListener(() {
        _updates['details'] = detailsController.text != widget.record!.details
            ? detailsController.text
            : null;
      });
    }
  }

  void _saveRec(String itemName, String cost) async {
    try {
      await _recordChanger?.saveRecord(
        itemName,
        formatDate(_selectedDate!.toLocal()),
        cost,
        _selectedCategory.toString(),
        _imageField,
        _isFavourited,
        details,
      );
      if (!mounted) return;
      //change _errorMessage to be nothing on success
      setState(() {
        _errorMessage = null;
      });
    } on FormatException {
      setState(() {
        _errorMessage =
            "Remember: use date picker for Date and key in a valid value for cost";
      });
      if (!mounted) return;
    } catch (e) {
      setState(() {
        debugPrint(e.toString());
        _errorMessage = "Unexpected error. Please try again later. ";
      });
    }
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
                        existing_base64: _imageField,
                        backgroundTextStyle: backgroundTextStyle,
                        sendBack64: (base64) => setState(() {
                          _imageField = base64;
                        }),
                      ),
                      _buildActionRow(width, height),
                      ShowErrorMessage(errorMessage: _errorMessage),
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
              if (widget.record == null || widget.record?.record_id == null) {
                itemName = itemNameController.text;
                cost = costController.text;
                AsyncSnapshot.waiting();
                _saveRec(itemName!, cost!);
              } else if (widget.record != null) {
                debugPrint('ERROR IN _buildActionRow entered != null');
                debugPrint('HEREEEE final _updates: $_updates');
                AsyncSnapshot.waiting();
                debugPrint('BEFORE IF-ELSE $_isFavourited VS $_originalFav');
                if (_isFavourited != _originalFav) {
                  debugPrint('ENTERED IF-ELSE $_isFavourited vs $_originalFav');
                  _updates['isFavourited'] = _isFavourited;
                  debugPrint(_updates.toString());
                }
                if (_imageField != _originalBase64) {
                  _updates['photo'] = _imageField;
                }
                debugPrint(_updates.toString());
                _patchRecord(widget.record!);
              }
            }
            Navigator.of(context).pop();
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

  void _patchRecord(Record record) async {
    try {
      await _recordChanger?.patchRecord(record, _updates);
      debugPrint("RECORD SERVICES SENT AND RETURNED");

      if (!mounted) return;
      //change _errorMessage to be nothing on success
      setState(() {
        _errorMessage = null;
      });
    } on FormatException {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            "Remember: use date picker for Date and key in a valid value for cost";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        // TODO : CHANGE BACK "Unexpected error. Please try again later. ";
      });
    }
  }

  //MOVE CATEGORY SELECTOR TO NEW FILE
  DropdownMenu<CategoryItem> _buildCatDropdown(
    BoxConstraints constraints,
    InputDecorationTheme optionalInputdecorationtheme,
  ) {
    return DropdownMenu<CategoryItem>(
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
      onSelected: (CategoryItem? cat) {
        setState(() {
          _selectedCategory = cat;
        });
      },
      controller: categoryController,
      enableFilter: false,
      requestFocusOnTap: false,
      leadingIcon: const Icon(Icons.category_rounded, color: Colours.darkBrown),
      label: Text(
        "Add a category label",
        textAlign: TextAlign.center,
        style: backgroundTextStyle,
      ),
      dropdownMenuEntries: categories
          .map((item) => DropdownMenuEntry(value: item, label: item.labelText))
          .toList(),
    );
  }

  //TODO: MOVE DETAILS TO NEW FIELD
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

  //TODO: MOVE DATE FIELD TO NEW FILE ALONG WITH DATE PICKER
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _selectedDate ?? DateTime.now(),
    );
    if (!mounted) return;

    if (date != null) {
      setState(() {
        _selectedDate = date.toLocal();
      });
      dateController.text = formatDate(_selectedDate!);
    }
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

  //TODO: MOVE ITEMNAME FIELD TO NEW FILE
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
