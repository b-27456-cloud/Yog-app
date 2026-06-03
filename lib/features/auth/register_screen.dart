import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/glass_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      prefixIcon: Icon(icon, color: AppColors.kSkyBlue),
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.65)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.20)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.kSkyBlue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        isDark: true,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Text(
                  "Create Account",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Start your yoga journey",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 40),
                GlassCard(
                  isDark: true,
                  borderRadius: 20,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name Field
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        cursorColor: AppColors.kSkyBlue,
                        decoration: _buildInputDecoration("Full Name", Icons.person_outline),
                      ),
                      const SizedBox(height: 16),
                      // Email Field
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        cursorColor: AppColors.kSkyBlue,
                        decoration: _buildInputDecoration("Email", Icons.email_outlined),
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextField(
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: AppColors.kSkyBlue,
                        decoration: _buildInputDecoration("Password", Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white.withOpacity(0.65),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password Field
                      TextField(
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: Colors.white),
                        cursorColor: AppColors.kSkyBlue,
                        decoration: _buildInputDecoration("Confirm Password", Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white.withOpacity(0.65),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Terms and Privacy Policy
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreedToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreedToTerms = value ?? false;
                                });
                              },
                              activeColor: AppColors.kPrimary,
                              side: BorderSide(color: Colors.white.withOpacity(0.65)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "I agree to Terms & Privacy Policy",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Create Account Button
                      GestureDetector(
                        onTap: () {
                          context.go('/home');
                        },
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.kPrimary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.kPrimary.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Create Account",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: AppColors.kSkyBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
