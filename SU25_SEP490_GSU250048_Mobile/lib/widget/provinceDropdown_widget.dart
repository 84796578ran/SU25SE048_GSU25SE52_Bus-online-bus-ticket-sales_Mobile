// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:collection/collection.dart';
// import '../models/location.dart';
//
// class ProvinceDropdown extends StatelessWidget {
//   final String label;
//   final String? selectedProvince;
//   final List<Location> provinces;
//   final ValueChanged<String?> onChanged;
//
//   const ProvinceDropdown({
//     required this.label,
//     required this.selectedProvince,
//     required this.onChanged,
//     required this.provinces,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final Location? selectedLocationObject = selectedProvince != null && provinces.isNotEmpty
//         ? provinces.firstWhereOrNull(
//           (province) => province.name == selectedProvince,
//     )
//         : null;
//     return DropdownSearch<Location>(
//       selectedItem: selectedLocationObject,
//       onChanged: (Location? selectedLocation) {
//         onChanged(selectedLocation?.name);
//       },
//       items: provinces,
//       itemAsString: (Location province) => province.name,
//       popupProps: const PopupProps.dialog(
//         showSearchBox: true,
//        // constraints: BoxConstraints(maxHeight: 400, maxWidth: 300),
//         scrollbarProps: ScrollbarProps(thumbVisibility: true),
//       ),
//       dropdownDecoratorProps: DropDownDecoratorProps(
//         dropdownSearchDecoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }