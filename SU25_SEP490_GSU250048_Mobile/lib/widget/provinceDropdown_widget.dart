import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ProvinceDropdown extends StatelessWidget {
  final String label;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const ProvinceDropdown({
    required this.label,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      selectedItem: selected,
      onChanged: onChanged,
      //items: Provinces.all,
      popupProps: const PopupProps.dialog(
        showSearchBox: true,
        constraints: BoxConstraints(maxHeight: 400, maxWidth: 300),
        scrollbarProps: ScrollbarProps(thumbVisibility:  true),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
