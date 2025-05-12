import 'package:flutter/material.dart';

class CropSelectorDialog extends StatefulWidget {
  final Function(String) onCropSelected;

  const CropSelectorDialog({
    Key? key,
    required this.onCropSelected,
  }) : super(key: key);

  @override
  _CropSelectorDialogState createState() => _CropSelectorDialogState();
}

class _CropSelectorDialogState extends State<CropSelectorDialog> {
  final List<Map<String, dynamic>> _cropGroups = [
    {
      'name': 'अनाज',
      'crops': [
        'गेहूं',
        'चावल',
        'मक्का',
        'बाजरा',
        'ज्वार',
      ],
    },
    {
      'name': 'दालें',
      'crops': [
        'चना',
        'अरहर',
        'मूंग',
        'मसूर',
        'उड़द',
      ],
    },
    {
      'name': 'तिलहन',
      'crops': [
        'सरसों',
        'सोयाबीन',
        'मूंगफली',
        'तिल',
        'सूरजमुखी',
      ],
    },
    {
      'name': 'सब्जियां',
      'crops': [
        'आलू',
        'टमाटर',
        'प्याज',
        'भिंडी',
        'मिर्च',
        'बैंगन',
        'गोभी',
        'मटर',
      ],
    },
    {
      'name': 'फल',
      'crops': [
        'आम',
        'केला',
        'सेब',
        'अंगूर',
        'पपीता',
      ],
    },
    {
      'name': 'नकदी फसलें',
      'crops': [
        'कपास',
        'गन्ना',
        'तम्बाकू',
        'जूट',
      ],
    },
  ];

  String? _searchQuery;
  List<String> _searchResults = [];

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.trim();
      if (_searchQuery!.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _getAllCrops()
            .where((crop) =>
                crop.toLowerCase().contains(_searchQuery!.toLowerCase()))
            .toList();
      }
    });
  }

  List<String> _getAllCrops() {
    List<String> allCrops = [];
    for (var group in _cropGroups) {
      allCrops.addAll(group['crops'] as List<String>);
    }
    return allCrops;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('फसल चुनें'),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search box
            TextField(
              decoration: InputDecoration(
                hintText: 'फसल खोजें',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 16),
            
            // Crop list with categories
            Expanded(
              child: _searchQuery != null && _searchQuery!.isNotEmpty
                  ? _buildSearchResults()
                  : _buildCropCategories(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('रद्द करें'),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('कोई परिणाम नहीं मिला'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_searchResults[index]),
          onTap: () {
            Navigator.of(context).pop();
            widget.onCropSelected(_searchResults[index]);
          },
        );
      },
    );
  }

  Widget _buildCropCategories() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _cropGroups.length,
      itemBuilder: (context, index) {
        final group = _cropGroups[index];
        return ExpansionTile(
          title: Text(
            group['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: (group['crops'] as List<String>).map((crop) {
            return ListTile(
              title: Text(crop),
              onTap: () {
                Navigator.of(context).pop();
                widget.onCropSelected(crop);
              },
            );
          }).toList(),
        );
      },
    );
  }
}