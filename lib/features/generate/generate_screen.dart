import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/glass_card.dart';
import 'widgets/barcode_type_selector.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController _controller = TextEditingController();
  String _data = '';
  CustomBarcodeType _selectedType = CustomBarcodeType.qrCode;
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _data = query;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Generate Code'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Field
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Enter Data',
                hintText: 'Type text, URL, or numbers',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                prefixIcon: const Icon(Icons.text_fields),
              ),
            ),
            const SizedBox(height: 24),
            
            // Format Selector
            Text(
              'Select Format',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            BarcodeTypeSelector(
              selectedType: _selectedType,
              onChanged: (type) {
                setState(() {
                  _selectedType = type;
                });
              },
            ),
            const SizedBox(height: 32),
            
            // Preview Card
            GlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _data.isEmpty
                        ? Container(
                            key: const ValueKey('empty'),
                            height: 200,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 64,
                                  color: Colors.grey.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Preview will appear here',
                                  style: TextStyle(color: Colors.grey.withValues(alpha: 0.7)),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            key: ValueKey('$_data$_selectedType'),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _buildBarcodePreview(),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _data.isEmpty ? null : () {},
                    icon: const Icon(Icons.save),
                    label: const Text('Save Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _data.isEmpty ? null : () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodePreview() {
    try {
      if (_selectedType == CustomBarcodeType.qrCode) {
        return QrImageView(
          data: _data,
          version: QrVersions.auto,
          size: 200.0,
          backgroundColor: Colors.white,
        );
      } else {
        return BarcodeWidget(
          data: _data,
          barcode: _getBarcodeFormat(_selectedType),
          width: double.infinity,
          height: 120.0,
          backgroundColor: Colors.white,
          errorBuilder: (context, error) => Center(
            child: Text(error, style: const TextStyle(color: Colors.red)),
          ),
        );
      }
    } catch (e) {
      return Center(
        child: Text('Invalid data for this format', style: const TextStyle(color: Colors.red)),
      );
    }
  }

  Barcode _getBarcodeFormat(CustomBarcodeType type) {
    switch (type) {
      case CustomBarcodeType.code128:
        return Barcode.code128();
      case CustomBarcodeType.ean13:
        return Barcode.ean13();
      case CustomBarcodeType.upcA:
        return Barcode.upcA();
      default:
        return Barcode.code128();
    }
  }
}
