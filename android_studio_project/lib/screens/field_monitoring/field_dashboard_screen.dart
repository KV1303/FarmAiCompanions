import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_images.dart';
import '../../providers/auth_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/field/field_card.dart';
import '../../widgets/field/ndvi_chart.dart';
import '../../utils/localization.dart';
import '../../models/field_model.dart';

class FieldDashboardScreen extends StatefulWidget {
  const FieldDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FieldDashboardScreen> createState() => _FieldDashboardScreenState();
}

class _FieldDashboardScreenState extends State<FieldDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _cropTypeController = TextEditingController();
  final _areaController = TextEditingController();
  String _areaUnit = 'acres';
  DateTime _sowingDate = DateTime.now();
  DateTime _expectedHarvestDate = DateTime.now().add(const Duration(days: 90));
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFields();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _cropTypeController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _loadFields() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null && fieldProvider.fields.isEmpty) {
      await fieldProvider.fetchFields(user.id);
    }
  }

  Future<void> _refreshFields() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      await fieldProvider.fetchFields(user.id);
    }
  }

  Future<void> _refreshFieldData() async {
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    if (fieldProvider.selectedField != null) {
      await fieldProvider.refreshFieldData(fieldProvider.selectedField!.id);
    }
  }

  void _showAddFieldDialog() {
    // Reset form fields
    _nameController.clear();
    _cropTypeController.clear();
    _areaController.clear();
    _areaUnit = 'acres';
    _sowingDate = DateTime.now();
    _expectedHarvestDate = DateTime.now().add(const Duration(days: 90));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.addNewField),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Field name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Field Name',
                    hintText: 'Enter a name for your field',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a field name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Crop type
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Crop Type',
                  ),
                  items: AppStrings.cropTypes.map((crop) {
                    return DropdownMenuItem<String>(
                      value: crop,
                      child: Text(crop),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _cropTypeController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a crop type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Field area
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _areaController,
                        decoration: const InputDecoration(
                          labelText: 'Area',
                          hintText: 'e.g., 2.5',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter field area';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _areaUnit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'acres', child: Text('Acres')),
                          DropdownMenuItem(value: 'hectares', child: Text('Hectares')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _areaUnit = value ?? 'acres';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Sowing date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sowing Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(_sowingDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _sowingDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    
                    if (date != null) {
                      setState(() {
                        _sowingDate = date;
                        // Recalculate expected harvest date based on crop type
                        _expectedHarvestDate = _calculateHarvestDate(date, _cropTypeController.text);
                      });
                    }
                  },
                ),
                
                // Expected harvest date
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Expected Harvest Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(_expectedHarvestDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expectedHarvestDate,
                      firstDate: _sowingDate,
                      lastDate: DateTime(2030),
                    );
                    
                    if (date != null) {
                      setState(() {
                        _expectedHarvestDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textLightColor),
            ),
          ),
          ElevatedButton(
            onPressed: _addField,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Add Field'),
          ),
        ],
      ),
    );
  }

  DateTime _calculateHarvestDate(DateTime sowingDate, String cropType) {
    // Default growing period in days
    int growingPeriod = 90;
    
    // Assign growing periods based on crop type
    switch (cropType.toLowerCase()) {
      case 'rice':
        growingPeriod = 120;
        break;
      case 'wheat':
        growingPeriod = 135;
        break;
      case 'maize':
        growingPeriod = 100;
        break;
      case 'cotton':
        growingPeriod = 180;
        break;
      case 'sugarcane':
        growingPeriod = 365;
        break;
      case 'soybean':
        growingPeriod = 100;
        break;
      case 'groundnut':
        growingPeriod = 120;
        break;
      case 'mustard':
        growingPeriod = 110;
        break;
      case 'potato':
        growingPeriod = 90;
        break;
      case 'tomato':
        growingPeriod = 80;
        break;
      case 'onion':
        growingPeriod = 120;
        break;
      case 'chilli':
        growingPeriod = 90;
        break;
    }
    
    return sowingDate.add(Duration(days: growingPeriod));
  }

  Future<void> _addField() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user != null) {
        final success = await fieldProvider.addField(
          user.id,
          _nameController.text.trim(),
          _cropTypeController.text.trim(),
          double.parse(_areaController.text.trim()),
          _areaUnit,
          user.latitude,
          user.longitude,
          _sowingDate,
          _expectedHarvestDate,
        );
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Field added successfully'),
              backgroundColor: AppColors.successColor,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(fieldProvider.error),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteField(String fieldId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Field'),
        content: const Text('Are you sure you want to delete this field? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textLightColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user != null) {
        final success = await fieldProvider.deleteField(fieldId, user.id);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Field deleted successfully'),
              backgroundColor: AppColors.successColor,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(fieldProvider.error),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final fieldProvider = Provider.of<FieldProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final localization = AppLocalizations.of(context);
    
    if (authProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }
    
    final user = authProvider.user;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localization?.translate(AppStrings.fieldMonitoring) ?? AppStrings.fieldMonitoring,
      ),
      body: fieldProvider.isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: _refreshFields,
              color: AppColors.primaryColor,
              child: Column(
                children: [
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: AppColors.textLightColor,
                    indicatorColor: AppColors.primaryColor,
                    tabs: const [
                      Tab(text: 'Fields'),
                      Tab(text: 'Monitoring'),
                    ],
                  ),
                  
                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Fields tab
                        _FieldsTab(
                          onAddField: _showAddFieldDialog,
                          onDeleteField: _deleteField,
                        ),
                        
                        // Monitoring tab
                        _MonitoringTab(
                          onRefresh: _refreshFieldData,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddFieldDialog,
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _FieldsTab extends StatelessWidget {
  final Function onAddField;
  final Function(String) onDeleteField;

  const _FieldsTab({
    Key? key,
    required this.onAddField,
    required this.onDeleteField,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fieldProvider = Provider.of<FieldProvider>(context);
    
    if (fieldProvider.fields.isEmpty) {
      return _EmptyFieldsView(onAddField: onAddField);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fieldProvider.fields.length,
      itemBuilder: (context, index) {
        final field = fieldProvider.fields[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _FieldListItem(
            field: field,
            onTap: () {
              fieldProvider.selectField(field.id);
            },
            onDelete: () => onDeleteField(field.id),
          ),
        );
      },
    );
  }
}

class _FieldListItem extends StatelessWidget {
  final Field field;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FieldListItem({
    Key? key,
    required this.field,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field image with overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  // Field image
                  Image.network(
                    field.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 140,
                        color: AppColors.primaryLightColor.withOpacity(0.2),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: AppColors.primaryColor.withOpacity(0.5),
                          ),
                        ),
                      );
                    },
                  ),
                  // Dark overlay with field name
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              field.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getHealthColor(field.healthStatus),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              field.healthStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Field details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop type and area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.grass,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            field.cropType,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.straighten,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${field.area} ${field.areaUnit}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Sowing date and growth stage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sown: ${DateFormat('MMM dd, yyyy').format(field.sowingDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLightColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Stage: ${field.growthStage}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // NDVI and soil moisture indicators
                  Row(
                    children: [
                      Expanded(
                        child: _IndicatorBar(
                          label: 'NDVI',
                          value: field.ndviIndex,
                          maxValue: 1.0,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _IndicatorBar(
                          label: 'Soil Moisture',
                          value: field.soilMoisture,
                          maxValue: 100,
                          color: AppColors.accentColor,
                          suffix: '%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.errorColor,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Delete field',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(String health) {
    switch (health.toLowerCase()) {
      case 'good':
        return AppColors.successColor;
      case 'fair':
        return AppColors.warningColor;
      case 'poor':
        return AppColors.errorColor;
      default:
        return AppColors.successColor;
    }
  }
}

class _IndicatorBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final String suffix;

  const _IndicatorBar({
    Key? key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    this.suffix = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(2)}$suffix',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / maxValue,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _EmptyFieldsView extends StatelessWidget {
  final Function onAddField;

  const _EmptyFieldsView({
    Key? key,
    required this.onAddField,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grass,
              size: 80,
              color: AppColors.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No fields added yet',
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Add your first field to start monitoring your crops',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLightColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: localization?.translate(AppStrings.addNewField) ?? AppStrings.addNewField,
              onPressed: () => onAddField(),
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonitoringTab extends StatelessWidget {
  final Function onRefresh;

  const _MonitoringTab({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fieldProvider = Provider.of<FieldProvider>(context);
    final selectedField = fieldProvider.selectedField;
    
    if (selectedField == null) {
      return const Center(
        child: Text(
          'Select a field to view monitoring data',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textLightColor,
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Field thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    selectedField.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.primaryLightColor.withOpacity(0.2),
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: AppColors.primaryColor.withOpacity(0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Field details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedField.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedField.cropType} - ${selectedField.area} ${selectedField.areaUnit}',
                        style: const TextStyle(
                          color: AppColors.textLightColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Growth Stage: ${selectedField.growthStage}',
                        style: TextStyle(
                          color: AppColors.accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // NDVI and health section
          Text(
            'Field Health',
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NDVI chart
                const Text(
                  'NDVI Index',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Normalized Difference Vegetation Index measures vegetation health',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLightColor,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: NdviChart(
                    ndviValue: selectedField.ndviIndex,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Soil moisture
                const Text(
                  'Soil Moisture',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current soil moisture level in your field',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLightColor,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: selectedField.soilMoisture / 100,
                  backgroundColor: AppColors.accentColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentColor),
                  minHeight: 30,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dry',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLightColor,
                      ),
                    ),
                    Text(
                      '${selectedField.soilMoisture.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentColor,
                      ),
                    ),
                    Text(
                      'Wet',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLightColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Growth timeline
          Text(
            'Growth Timeline',
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _GrowthTimelineItem(
                  stage: 'Sowing',
                  date: selectedField.sowingDate,
                  isCompleted: true,
                  isFirst: true,
                ),
                _GrowthTimelineItem(
                  stage: 'Germination',
                  date: selectedField.sowingDate.add(const Duration(days: 10)),
                  isCompleted: DateTime.now().isAfter(
                    selectedField.sowingDate.add(const Duration(days: 10)),
                  ),
                ),
                _GrowthTimelineItem(
                  stage: 'Vegetative',
                  date: selectedField.sowingDate.add(const Duration(days: 30)),
                  isCompleted: DateTime.now().isAfter(
                    selectedField.sowingDate.add(const Duration(days: 30)),
                  ),
                ),
                _GrowthTimelineItem(
                  stage: 'Flowering',
                  date: selectedField.sowingDate.add(const Duration(days: 60)),
                  isCompleted: DateTime.now().isAfter(
                    selectedField.sowingDate.add(const Duration(days: 60)),
                  ),
                ),
                _GrowthTimelineItem(
                  stage: 'Harvest',
                  date: selectedField.expectedHarvestDate,
                  isCompleted: DateTime.now().isAfter(selectedField.expectedHarvestDate),
                  isLast: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Refresh button
          Center(
            child: CustomButton(
              text: 'Refresh Field Data',
              onPressed: () => onRefresh(),
              icon: Icons.refresh,
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _GrowthTimelineItem extends StatelessWidget {
  final String stage;
  final DateTime date;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  const _GrowthTimelineItem({
    Key? key,
    required this.stage,
    required this.date,
    required this.isCompleted,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Line
                if (!isFirst)
                  Positioned(
                    top: 0,
                    bottom: isLast ? 20 : null,
                    height: isLast ? null : 40,
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                    ),
                  ),
                
                // Dot
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppColors.primaryColor : Colors.white,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
          
          // Stage and date
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? AppColors.primaryColor
                          : AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLightColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
