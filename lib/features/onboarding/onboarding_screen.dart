import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'imagePath': 'assets/images/onboarding_pose.png',
      'title': 'Detect Your Pose',
      'subtitle': 'Real-time AI identifies your yoga posture and guides corrections instantly',
    },
    {
      'imagePath': 'assets/images/onboarding_progress.png',
      'title': 'Track Your Progress',
      'subtitle': 'See your accuracy improve over time with detailed session analytics',
    },
    {
      'imagePath': 'assets/images/onboarding_journey.png',
      'title': 'Your Yoga Journey',
      'subtitle': 'Personalized pose sessions tailored to your level and daily goals',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  void _onSkip() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.kNavy,
              AppColors.kNavyDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // PageView
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Column(
                    children: [
                      // Top 50%: Illustration Area
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.kSteelBlue.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: GlassCard(
                                  isDark: true,
                                  borderRadius: 90,
                                  padding: EdgeInsets.zero,
                                  child: Center(
                                    child: ClipOval(
                                      child: Image.asset(
                                        page['imagePath'],
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Bottom 50%: Text Area
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              page['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Text(
                                page['subtitle'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white.withOpacity(0.65),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Skip Button
              Positioned(
                top: 8,
                right: 16,
                child: TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    "Skip",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // Bottom Area (Positioned)
              Positioned(
                bottom: 32,
                left: 24,
                right: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.kPrimary
                                : Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Primary Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage == 2
                              ? AppColors.kSkyBlue
                              : AppColors.kPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == 2 ? "Get Started" : "Continue",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
