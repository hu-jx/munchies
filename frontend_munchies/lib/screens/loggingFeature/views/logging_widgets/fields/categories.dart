import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/category_item.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/logging_form_styles.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class CategoryMenu extends StatefulWidget {
  final TextEditingController categoryController;
  final Function sendBackCat;
  final double maxWidth;
  const CategoryMenu({super.key, required this.categoryController, required this.sendBackCat, required this.maxWidth});

  static final List<CategoryItem> categories =
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
  @override
  State<CategoryMenu> createState() => _CategoryMenuState();
}

class _CategoryMenuState extends State<CategoryMenu> {
  

  CategoryItem? _selectedCategory;
  @override
  Widget build(BuildContext context) {
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
      width: widget.maxWidth,
      inputDecorationTheme: optionalInputdecorationtheme,
      onSelected: (CategoryItem? cat) {
        setState(() {
          _selectedCategory = cat;
        });
        widget.categoryController.text = _selectedCategory?.labelText ?? '';
        widget.sendBackCat(_selectedCategory);
      },
      controller: widget.categoryController,
      enableFilter: false,
      requestFocusOnTap: false,
      leadingIcon: const Icon(Icons.category_rounded, color: Colours.darkBrown),
      label: Text(
        "Add a category label",
        textAlign: TextAlign.center,
        style: backgroundTextStyle,
      ),
      dropdownMenuEntries: CategoryMenu.categories
          .map((item) => DropdownMenuEntry(value: item, label: item.labelText))
          .toList(),
    );
  }
}