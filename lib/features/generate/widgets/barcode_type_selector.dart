import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum CustomBarcodeType { qrCode, code128, ean13, upcA }

class BarcodeTypeSelector extends StatelessWidget {
  final CustomBarcodeType selectedType;
  final ValueChanged<CustomBarcodeType> onChanged;

  const BarcodeTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: CustomBarcodeType.values.map((type) {
          final isSelected = selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_getLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onChanged(type);
              },
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(CustomBarcodeType type) {
    switch (type) {
      case CustomBarcodeType.qrCode:
        return 'QR Code';
      case CustomBarcodeType.code128:
        return 'Code 128';
      case CustomBarcodeType.ean13:
        return 'EAN 13';
      case CustomBarcodeType.upcA:
        return 'UPC-A';
    }
  }
}
