
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class GenericDropdownSearch<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemAsString;
  final ValueChanged<T?>? onChanged;
  final String labelText;
  final String? hintText;
  final FormFieldValidator<T?>? validator;
  final bool enabled;
  final bool showSearchBox;

  const GenericDropdownSearch({
    super.key,
    required this.items,
    this.selectedItem,
    required this.itemAsString,
    this.onChanged,
    required this.labelText,
    this.hintText,
    this.validator,
    this.enabled = true, // Mặc định là enabled
    this.showSearchBox = true, // Mặc định hiển thị hộp tìm kiếm
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox( // Bọc trong SizedBox để cung cấp ràng buộc chiều rộng
      width: double.infinity,
      child: DropdownSearch<T>(
        selectedItem: selectedItem,
        items: items,
        itemAsString: itemAsString,
        onChanged: onChanged,
        enabled: enabled,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        popupProps: showSearchBox
            ? const PopupProps.menu( // Hoặc .dialog nếu bạn thích popup lớn hơn
          showSearchBox: true,
          // Bỏ constraints ở đây để tránh lỗi RenderShrinkWrappingViewport
          // constraints: BoxConstraints(maxHeight: 400, maxWidth: 300),
          scrollbarProps: ScrollbarProps(thumbVisibility: true),
        )
            : const PopupProps.menu(
          // Nếu không có tìm kiếm, chỉ cần menu cơ bản
          // constraints: BoxConstraints(maxHeight: 400, maxWidth: 300),
          scrollbarProps: ScrollbarProps(thumbVisibility: true),
        ),
        validator: validator,
      ),
    );
  }
}