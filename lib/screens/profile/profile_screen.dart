import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../utils/validators.dart';
import '../../utils/localization.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _locationController.text = user.location;
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      
      if (!_isEditing) {
        // Reset form if cancelling
        _loadUserData();
      }
    });
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.updateUserProfile(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _locationController.text.trim(),
      );
      
      setState(() {
        _isEditing = false;
      });
      
      if (mounted) {
        if (authProvider.error.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error),
              backgroundColor: AppColors.errorColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.successColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
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
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _changeLanguage() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              name: 'English',
              code: 'en',
              isSelected: languageProvider.isEnglish,
              onTap: () {
                languageProvider.changeLanguage('en');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              name: 'हिंदी (Hindi)',
              code: 'hi',
              isSelected: languageProvider.isHindi,
              onTap: () {
                languageProvider.changeLanguage('hi');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localization = AppLocalizations.of(context);
    
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }
    
    final user = authProvider.user;
    
    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Profile',
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You need to login first',
                style: TextStyle(
                  color: AppColors.textLightColor,
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Go to Login',
                onPressed: () => Navigator.pushReplacementNamed(context, AppConstants.routeLogin),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localization?.translate(AppStrings.profile) ?? AppStrings.profile,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditing,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Name
                    if (!_isEditing)
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    
                    // Email
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: AppColors.textLightColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Profile form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization?.translate(AppStrings.editProfile) ?? AppStrings.editProfile,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Profile fields
                    if (_isEditing) ...[
                      // Name field
                      CustomTextField(
                        controller: _nameController,
                        labelText: localization?.translate(AppStrings.name) ?? AppStrings.name,
                        prefixIcon: const Icon(Icons.person),
                        validator: (value) => Validators.validateName(value, localization),
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone field
                      CustomTextField(
                        controller: _phoneController,
                        labelText: localization?.translate(AppStrings.phoneNumber) ?? AppStrings.phoneNumber,
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                        validator: (value) => Validators.validatePhone(value, localization),
                      ),
                      const SizedBox(height: 16),
                      
                      // Location field
                      CustomTextField(
                        controller: _locationController,
                        labelText: localization?.translate(AppStrings.location) ?? AppStrings.location,
                        prefixIcon: const Icon(Icons.location_on),
                        validator: (value) => Validators.validateLocation(value, localization),
                      ),
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: localization?.translate(AppStrings.cancel) ?? AppStrings.cancel,
                              onPressed: _toggleEditing,
                              backgroundColor: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomButton(
                              text: localization?.translate(AppStrings.save) ?? AppStrings.save,
                              onPressed: _updateProfile,
                              isLoading: authProvider.isLoading,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // View mode - display profile info
                      _ProfileInfoItem(
                        icon: Icons.person,
                        label: localization?.translate(AppStrings.name) ?? AppStrings.name,
                        value: user.name,
                      ),
                      _ProfileInfoItem(
                        icon: Icons.phone,
                        label: localization?.translate(AppStrings.phoneNumber) ?? AppStrings.phoneNumber,
                        value: user.phone,
                      ),
                      _ProfileInfoItem(
                        icon: Icons.location_on,
                        label: localization?.translate(AppStrings.location) ?? AppStrings.location,
                        value: user.location,
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Settings section
              Text(
                localization?.translate(AppStrings.settings) ?? AppStrings.settings,
                style: Theme.of(context).textTheme.headline3,
              ),
              const SizedBox(height: 16),
              
              // Language settings
              _SettingsItem(
                icon: Icons.language,
                title: localization?.translate(AppStrings.language) ?? AppStrings.language,
                subtitle: languageProvider.isEnglish ? 'English' : 'हिंदी',
                onTap: _changeLanguage,
              ),
              
              // About
              _SettingsItem(
                icon: Icons.info_outline,
                title: localization?.translate(AppStrings.about) ?? AppStrings.about,
                subtitle: 'App version 1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: AppStrings.appName,
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(
                      Icons.eco,
                      color: AppColors.primaryColor,
                      size: 40,
                    ),
                    children: [
                      const Text(
                        'FarmAssist AI is an AI-driven farming companion app that helps farmers with crop monitoring, disease detection, and market prices.',
                      ),
                    ],
                  );
                },
              ),
              
              // Help
              _SettingsItem(
                icon: Icons.help_outline,
                title: localization?.translate(AppStrings.help) ?? AppStrings.help,
                subtitle: 'Get assistance with using the app',
                onTap: () {
                  // Show help dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help feature coming soon'),
                    ),
                  );
                },
              ),
              
              // Privacy Policy
              _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: localization?.translate(AppStrings.privacyPolicy) ?? AppStrings.privacyPolicy,
                subtitle: isHindi ? 'गोपनीयता नीति पढ़ें' : 'Read our privacy policy',
                onTap: () {
                  Navigator.pushNamed(context, AppConstants.routePrivacyPolicy);
                },
              ),
              
              const SizedBox(height: 32),
              
              // Logout button
              CustomButton(
                text: localization?.translate(AppStrings.logout) ?? AppStrings.logout,
                onPressed: _logout,
                backgroundColor: AppColors.errorColor,
                icon: Icons.logout,
              ),
              
              const SizedBox(height: 24),
              
              // Footer
              Center(
                child: Text(
                  '© 2023 FarmAssist AI',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLightColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLightColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textLightColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String name;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    Key? key,
    required this.name,
    required this.code,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryColor : AppColors.textColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
