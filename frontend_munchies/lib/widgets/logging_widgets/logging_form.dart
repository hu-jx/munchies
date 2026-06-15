//this is the default tracking page

// ignore_for_file: non_constant_identifier_names

import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/category_item.dart';
import 'package:frontend_munchies/services/records/record_changer.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/widgets/errorMessage.dart';
import 'package:frontend_munchies/widgets/image_widgets.dart/image_selection_button.dart';
import 'package:frontend_munchies/widgets/logging_widgets/fields/categories.dart';
import 'package:frontend_munchies/widgets/logging_widgets/fields/cost.dart';
import 'package:frontend_munchies/widgets/logging_widgets/fields/date.dart';
import 'package:frontend_munchies/widgets/logging_widgets/fields/details.dart';
import 'package:frontend_munchies/widgets/logging_widgets/fields/item_name.dart';
import 'package:frontend_munchies/widgets/logging_widgets/fields/others_row.dart';
import 'package:frontend_munchies/widgets/logging_widgets/fields/visibility_toggle.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TextEditingController itemNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  final RecordChanger recChange = RecordChanger();
  File? _imageField;
  var _isFavourited = false;
  var _isVisible = false;
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
    'isVisible': null,
  };
  late bool _originalFav;
  late String? _originalCategory;
  late bool _originalVisibility;
  String? itemName;
  String? cost;
  String? details;
  RecordChanger? _recordChanger;
  
  bool _isLoading = false;

  void checkIfUpdate() {
    if (widget.record != null) {
      _originalFav = widget.record!.isFavourited;
      _originalVisibility = widget.record!.isVisible;
      _selectedDate = widget.record!.date;
      dateController.text = DateField.formatDate(_selectedDate!);
      //FIXME: CAN DELETE THIS LINE. ORIGINAL PIC WILL NOT BE ALTERED
      // _originalBase64 = widget.record!.photo_URL;
      //if the record is a real existing record
      if (widget.record?.record_id != null) {
        setState(() {
          _isFavourited = _originalFav;
          _isVisible = _originalVisibility;
          _originalCategory = widget.record!.category != 'null'
              ? widget.record!.category
              : '';
              //FIXME: CAN DELETE THIS LINE. ORIGINAL PIC WILL NOT BE ALTERED ->
              // UPDATES ONLY GETS SMT WHEN WE HAVE A NEW FILE FOR UPLOAD
          // if (_originalBase64 != null) _imageField = _originalBase64;
          itemNameController.text = widget.record!.itemName;
          costController.text = (widget.record!.cost / 100).toStringAsFixed(2);
          if (widget.record!.details != null) {
            detailsController.text = widget.record!.details!;
          }
          if (_originalCategory != null) {
            _selectedCategory = CategoryMenu.categories.firstWhere(
              (str) => str.labelText == _originalCategory,
              orElse: () => CategoryItem(
                name: _originalCategory!,
                labelText: _originalCategory!,
              ),
            );
            categoryController.text = _selectedCategory?.labelText ?? '';
          }
        });
      } else if (widget.record != null && widget.record?.record_id == null) {
        //saving with favourite OR saving with AI
        setState(() {
          itemNameController.text = widget.record!.itemName;
          costController.text = (widget.record!.cost / 100).toStringAsFixed(2);
          _isFavourited = _originalFav;
          //FIXME: CAN DELETE THIS LINE. ORIGINAL PIC WILL NOT BE ALTERED ->
          // UPDATES ONLY GETS SMT WHEN WE HAVE A NEW FILE FOR UPLOAD
          // if (_originalBase64 != null) _imageField = _originalBase64;
        });
      }
    }
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
      details = detailsController.text;
      setState(() {
        _isLoading = true;
      });
      if (_isLoading) {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  color: Colours.greyPink,
                  
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
      await _recordChanger?.saveRecord(
        itemName,
        DateField.formatDate(_selectedDate!.toLocal()),
        cost,
        _selectedCategory?.labelText,
        //TODO: PASS THE FILE FROM IMAGESELECTIONBUTTON HERE
        _imageField,
        _isFavourited,
        details,
        _isVisible,
      );
      if (!mounted) return;
      //change _errorMessage to be nothing on success
      setState(() {
        _errorMessage = null;
        _isLoading = false;
      });
      Navigator.popUntil(context, (route) {
        return route.settings.name == '/home' || route.isFirst;
      });
    } on FormatException {
      setState(() {
        _errorMessage =
            "Remember: use date picker for Date and key in a valid value for cost.\n" 
            "Example of valid values: 4.80, 4. Do not include special characters like -, \$";
      });
      if (!mounted) return;
    } catch (e) {
      setState(() {
        // debugPrint(e.toString());
        _errorMessage = "Unexpected error. Please try again later. ";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      ItemName(itemNameController: itemNameController),
                      //DATE ROW
                      DateField(
                        dateController: dateController,
                        sendBackDate: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                      ),
                      //COST ROW
                      CostField(costController: costController),
                      //OTHER DETAILS BEGIN
                      OthersRow(),
                      //DETAILS
                      DetailsField(detailsController: detailsController),
                      //CATEGORY
                      CategoryMenu(
                        categoryController: categoryController,
                        sendBackCat: (cat) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        maxWidth: constraints.maxWidth,
                      ),
                      ImageSelectionButton(
                        boxSize: Size(width * 0.95, height * 0.3),
                        existing_url: widget.record?.photo_URL,
                        existing_photo_file: widget.record?.photo_file,
                        sendBackPhotoFile: (photo_file) => setState(() {
                          _imageField = photo_file;
                        }),
                      ),
                      VisibilityToggle(
                        original: widget.record?.isVisible,
                        formKey: _formKey,
                        sendVisibility: (boolean) {
                          setState(() {
                            _isVisible = boolean;
                          });
                        },
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
                cost = costController.text.trim();
                _saveRec(itemName!, cost!);
                //if it is an update
              } else if (widget.record != null) {
                if (_isFavourited != _originalFav) {
                  _updates['isFavourited'] = _isFavourited;
                }
                if (_imageField != null) {
                  _updates['photo'] = _imageField;
                }
                if (_originalCategory != _selectedCategory?.labelText) {
                  _updates['category'] = _selectedCategory?.labelText;
                }
                if (_isVisible != _originalVisibility) {
                  _updates['isVisible'] = _isVisible;
                }
                _patchRecord(widget.record!);
              }
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
      if (_imageField != null) {
        _updates['photo_file'] = _imageField;
      }
      setState(() {
        _isLoading = true;
      });
      if (_isLoading) {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colours.greyPink,
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
      await _recordChanger?.patchRecord(record, _updates);

      if (!mounted) return;
      //change _errorMessage to be nothing on success
      setState(() {
        _errorMessage = null;
        _isLoading = false;
      });
      Navigator.popUntil(context, (route) {
        return route.settings.name == '/home' || route.isFirst;
      });
    } on FormatException {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            "Remember: use date picker for Date and key in a valid value for cost.\n" 
            "Example of valid values: 4.80, 4. Do not include special characters like -, \$";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Unexpected error. Please try again later. ";
      });
    }
  }
}
