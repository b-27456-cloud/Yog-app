import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_yoga_female.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay to ensure text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.kNavy.withOpacity(0.3),
                    AppColors.kNavyDark.withOpacity(0.8),
                    AppColors.kNavyDark,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 3),
                          Text(
                            "Welcome Back",
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Sign in to your account",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                          const Spacer(flex: 2),
                          GlassCard(
                            isDark: true,
                            borderRadius: 20,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email Field
                                TextField(
                                  controller: _emailController,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: AppColors.kSkyBlue,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.12),
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: AppColors.kSkyBlue,
                                    ),
                                    labelText: "Email",
                                    labelStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.20),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.kSkyBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Password Field
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: AppColors.kSkyBlue,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.12),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.kSkyBlue,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white.withOpacity(0.65),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.20),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.kSkyBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: AppColors.kSkyBlue,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Sign In Button
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, child) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        if (authProvider.errorMessage != null) ...[
                                          Text(
                                            authProvider.errorMessage!,
                                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        GestureDetector(
                                          onTap: authProvider.isLoading
                                              ? null
                                              : () async {
                                                  final email = _emailController.text.trim();
                                                  final password = _passwordController.text.trim();
                                                  if (email.isEmpty || password.isEmpty) return;
                                                  
                                                  final success = await authProvider.login(email, password);
                                                  if (success && mounted) {
                                                    context.go('/home');
                                                  }
                                                },
                                          child: Container(
                                            width: double.infinity,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: authProvider.isLoading ? Colors.grey : AppColors.kPrimary,
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
                                              child: authProvider.isLoading
                                                  ? const SizedBox(
                                                      width: 24,
                                                      height: 24,
                                                      child: CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      "Sign In",
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
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Spacer(flex: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.white.withOpacity(0.65)),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go('/register');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: AppColors.kSkyBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // ── GOOGLE SIGN-IN COMMENTED OUT ──
                          // Row(
                          //   children: [
                          //     Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                          //     Padding(
                          //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          //       child: Text(
                          //         "or continue with",
                          //         style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                          //       ),
                          //     ),
                          //     Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                          //   ],
                          // ),
                          // const SizedBox(height: 24),
                          // GlassCard(
                          //   borderRadius: 14,
                          //   padding: EdgeInsets.zero,
                          //   child: InkWell(
                          //     onTap: () {},
                          //     borderRadius: BorderRadius.circular(14),
                          //     child: SizedBox(
                          //       height: 52,
                          //       width: double.infinity,
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: const [
                          //           Icon(Icons.g_mobiledata, color: Colors.white, size: 36),
                          //           SizedBox(width: 4),
                          //           Text(
                          //             "Continue with Google",
                          //             style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
