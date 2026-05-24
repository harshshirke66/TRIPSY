import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tripsy/core/theme/colors.dart';
import 'package:tripsy/core/widgets/glass_container.dart';
import 'package:tripsy/core/widgets/aurora_background.dart';
import 'package:tripsy/features/auth/presentation/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();

    // Navigate to Onboarding after 2.8 seconds
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Handcrafted Premium Glass Logo
                GlassContainer(
                  width: 104,
                  height: 104,
                  borderRadius: 32,
                  opacity: 0.08,
                  padding: EdgeInsets.zero,
                  borderSide: const BorderSide(
                    color: TripsyColors.sunsetOrange,
                    width: 2.5,
                  ),
                  shadows: [
                    BoxShadow(
                      color: TripsyColors.sunsetOrange.withValues(alpha: 0.4),
                      blurRadius: 48,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  child: const Center(
                    child: Icon(
                      Icons.explore_rounded,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                ShaderMask(
                  shaderCallback: (bounds) => TripsyColors.sunsetGradient.createShader(bounds),
                  child: const Text(
                    'Tripsy',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'DISCOVER. MATCH. TRAVEL.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4.0,
                    color: TripsyColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0.0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Find Your Next Adventure Buddy',
      subtitle: 'Swipe through profiles of global backpackers and local explorers looking for their next travel companion.',
      imageUrl: 'https://images.unsplash.com/photo-1501555088652-021faa106b9b?w=600&auto=format&fit=crop',
      accentColor: TripsyColors.sunsetOrange,
    ),
    OnboardingSlide(
      title: 'Plan Seamless Group Trips',
      subtitle: 'Create customized trip rooms, build shared visual timelines, and easily split travel expenses Splitwise-style.',
      imageUrl: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=600&auto=format&fit=crop',
      accentColor: TripsyColors.oceanTeal,
    ),
    OnboardingSlide(
      title: 'Share Your Travel Moments',
      subtitle: 'Publish real-time stories from your current destination, check-in on maps, and chat with instant matches.',
      imageUrl: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=600&auto=format&fit=crop',
      accentColor: TripsyColors.peachBurn,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _pageOffset = _pageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AuroraBackground(
        child: Stack(
          children: [
            // Background Parallax Page Slider
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                final slide = _slides[index];
                
                // Calculate parallax offset
                final parallaxOffset = (index - _pageOffset) * size.width * 0.35;
                
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image with Parallax Offset
                    Transform.translate(
                      offset: Offset(parallaxOffset, 0),
                      child: Image.network(
                        slide.imageUrl,
                        fit: BoxFit.cover,
                        color: Colors.black.withValues(alpha: 0.65),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                    
                    // Dark radial overlay gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.4),
                            TripsyColors.deepSpace.withValues(alpha: 0.85),
                            TripsyColors.deepSpace,
                          ],
                          stops: const [0.0, 0.3, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Foreground Floating Glass Card with content details
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: GlassContainer(
                borderRadius: 32,
                opacity: 0.05,
                borderSide: BorderSide(
                  color: _slides[_currentPage].accentColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                shadows: [
                  BoxShadow(
                    color: _slides[_currentPage].accentColor.withValues(alpha: 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _slides[_currentPage].title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _slides[_currentPage].subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: TripsyColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar & Navigation Dots
            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? LinearGradient(
                                  colors: [
                                    _slides[index].accentColor,
                                    _slides[index].accentColor.withValues(alpha: 0.6),
                                  ],
                                )
                              : null,
                          color: isActive ? null : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Action Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                        );
                      } else {
                        // Navigate to Auth Screen
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 1.0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 600),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _slides[_currentPage].accentColor,
                            _slides[_currentPage].accentColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: _slides[_currentPage].accentColor.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color accentColor;

  OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.accentColor,
  });
}
