import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../utils/validators.dart';
import '../../utils/localization.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Hide keyboard
      FocusScope.of(context).unfocus();
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim(),
        _locationController.text.trim(),
      );
      
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localization = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToLogin,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      localization?.translate(AppStrings.signUp) ?? AppStrings.signUp,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDarkColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account to start farming smartly',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textLightColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Name field
                    CustomTextField(
                      controller: _nameController,
                      labelText: localization?.translate(AppStrings.name) ?? AppStrings.name,
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (value) => Validators.validateName(value, localization),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      labelText: localization?.translate(AppStrings.email) ?? AppStrings.email,
                      hintText: 'example@email.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => Validators.validateEmail(value, localization),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Phone field
                    CustomTextField(
                      controller: _phoneController,
                      labelText: localization?.translate(AppStrings.phoneNumber) ?? AppStrings.phoneNumber,
                      hintText: '9876543210',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      validator: (value) => Validators.validatePhone(value, localization),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Location field
                    CustomTextField(
                      controller: _locationController,
                      labelText: localization?.translate(AppStrings.location) ?? AppStrings.location,
                      hintText: 'Enter your village/city',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      validator: (value) => Validators.validateLocation(value, localization),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: localization?.translate(AppStrings.password) ?? AppStrings.password,
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: !_passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textLightColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      validator: (value) => Validators.validatePassword(value, localization),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Confirm password field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      obscureText: !_confirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textLightColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                        localization,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Register button
                    authProvider.isLoading
                        ? const Center(child: LoadingIndicator())
                        : CustomButton(
                            text: localization?.translate(AppStrings.signUp) ?? AppStrings.signUp,
                            onPressed: _register,
                          ),
                    
                    const SizedBox(height: 24),
                    
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localization?.translate(AppStrings.alreadyHaveAccount) ?? AppStrings.alreadyHaveAccount,
                          style: const TextStyle(
                            color: AppColors.textLightColor,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToLogin,
                          child: Text(
                            localization?.translate(AppStrings.signIn) ?? AppStrings.signIn,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
