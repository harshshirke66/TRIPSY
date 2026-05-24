import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsy/core/models/profile_model.dart';
import 'package:tripsy/core/theme/colors.dart';
import 'package:tripsy/core/widgets/glass_container.dart';
import 'package:tripsy/core/providers/providers.dart';
import 'package:tripsy/features/chat/presentation/chat_screens.dart';
import 'package:tripsy/core/widgets/aurora_background.dart';

class SwipeDeckScreen extends ConsumerStatefulWidget {
  const SwipeDeckScreen({super.key});

  @override
  ConsumerState<SwipeDeckScreen> createState() => _SwipeDeckScreenState();
}

class _SwipeDeckScreenState extends ConsumerState<SwipeDeckScreen> with TickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  double _angle = 0.0;
  
  late AnimationController _swipeAnimationController;
  late Animation<Offset> _swipeAnimation;
  
  // Confetti particles for Match Popup
  final List<Particle> _particles = [];
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_swipeAnimationController);

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        if (mounted) {
          setState(() {
            for (var p in _particles) {
              p.update();
            }
          });
        }
      });
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerConfetti() {
    _particles.clear();
    final random = Random();
    for (int i = 0; i < 80; i++) {
      _particles.add(Particle(
        x: 180.0,
        y: 400.0,
        vx: (random.nextDouble() - 0.5) * 14.0,
        vy: (random.nextDouble() - 0.8) * 16.0,
        color: HSLColor.fromAHSL(
          1.0,
          random.nextDouble() * 360.0,
          0.8,
          0.6,
        ).toColor(),
        radius: random.nextDouble() * 4.0 + 3.0,
      ));
    }
    _confettiController.forward(from: 0.0);
  }

  void _animateSwipe(Offset target, VoidCallback onCompleted) {
    _swipeAnimation = Tween<Offset>(begin: _dragOffset, end: target).animate(
      CurvedAnimation(parent: _swipeAnimationController, curve: Curves.easeOutCubic),
    );
    _swipeAnimationController.forward(from: 0.0).then((_) {
      onCompleted();
      setState(() {
        _dragOffset = Offset.zero;
        _angle = 0.0;
        _isDragging = false;
      });
    });
  }

  void _performSwipe(Profile profile, String direction) {
    final screenWidth = MediaQuery.of(context).size.width;
    Offset target;
    if (direction == 'like') {
      target = Offset(screenWidth * 1.5, _dragOffset.dy);
    } else if (direction == 'pass') {
      target = Offset(-screenWidth * 1.5, _dragOffset.dy);
    } else {
      target = Offset(_dragOffset.dx, -MediaQuery.of(context).size.height);
    }

    _animateSwipe(target, () {
      ref.read(swipeDeckProvider.notifier).swipe(profile.id, direction);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(swipeDeckProvider);
    
    // Listen for match events to trigger confetti celebration
    ref.listen(swipeDeckProvider, (previous, next) {
      if (next.matchedWithUserId != null && previous?.matchedWithUserId == null) {
        _triggerConfetti();
      }
    });

    return Scaffold(
      body: AuroraBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Top Header Row
                  _buildHeader(),

                  // Stack Cards Deck
                  Expanded(
                    child: state.isLoading
                        ? const Center(child: CircularProgressIndicator(color: TripsyColors.sunsetOrange))
                        : state.profiles.isEmpty
                            ? _buildEmptyState()
                            : _buildCardDeck(state.profiles),
                  ),

                  // Bottom Action Buttons
                  if (state.profiles.isNotEmpty && !state.isLoading)
                    _buildActionButtons(state.profiles.last),
                  
                  const SizedBox(height: 80), // Nav bar padding
                ],
              ),
            ),

            // Confetti & Match Overlay Popup
            if (state.matchedWithUserId != null)
              _buildMatchOverlay(state.matchedWithUserId!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filter Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded, color: Colors.white),
            ),
          ),
          
          // Brand Title
          ShaderMask(
            shaderCallback: (bounds) => TripsyColors.sunsetGradient.createShader(bounds),
            child: const Text(
              'Tripsy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Notifications Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Icon(Icons.explore_off_rounded, size: 48, color: TripsyColors.textMuted),
          ),
          const SizedBox(height: 24),
          const Text(
            'No travelers nearby',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try expanding your filters or check back later.',
            style: TextStyle(fontSize: 14, color: TripsyColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(swipeDeckProvider.notifier).loadProfiles();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TripsyColors.sunsetOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Refresh Deck', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildCardDeck(List<Profile> profiles) {
    return Stack(
      clipBehavior: Clip.none,
      children: List.generate(profiles.length, (index) {
        final isTopCard = index == profiles.length - 1;
        final profile = profiles[index];

        return Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: isTopCard ? _buildDraggableCard(profile) : _buildBackgroundCard(index, profiles.length),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBackgroundCard(int index, int total) {
    final offsetFactor = (total - 1 - index) * 10.0;
    final scaleFactor = 1.0 - (total - 1 - index) * 0.04;
    final rotationAngle = (total - 1 - index) % 2 == 0 
        ? (total - 1 - index) * 0.025 
        : -(total - 1 - index) * 0.025;

    return Transform.translate(
      offset: Offset(0, offsetFactor),
      child: Transform.scale(
        scale: scaleFactor,
        child: Transform.rotate(
          angle: rotationAngle,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    ref.read(swipeDeckProvider).profiles[index].avatarUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableCard(Profile profile) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _dragOffset += details.delta;
            _angle = (_dragOffset.dx / constraints.maxWidth) * 0.25; // Tilt factor
          });
        },
        onPanEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond.dx;
          if (_dragOffset.dx > 120 || velocity > 400) {
            _performSwipe(profile, 'like');
          } else if (_dragOffset.dx < -120 || velocity < -400) {
            _performSwipe(profile, 'pass');
          } else if (_dragOffset.dy < -120) {
            _performSwipe(profile, 'super');
          } else {
            // Spring back
            _animateSwipe(Offset.zero, () {});
          }
        },
        child: AnimatedBuilder(
          animation: _swipeAnimationController,
          builder: (context, child) {
            final offset = _isDragging ? _dragOffset : _swipeAnimation.value;
            return Transform.translate(
              offset: offset,
              child: Transform.rotate(
                angle: _angle,
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // High Res Profile Avatar Card
                  Image.network(
                    profile.avatarUrl,
                    fit: BoxFit.cover,
                  ),
                  
                  // Shadow scrim overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // "LIKE" Stamp indicator overlay
                  if (_dragOffset.dx > 20)
                    Positioned(
                      top: 40,
                      left: 30,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: GlassContainer(
                          borderRadius: 16,
                          opacity: 0.1,
                          borderSide: const BorderSide(color: TripsyColors.activeGreen, width: 3.5),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shadows: [
                            BoxShadow(
                              color: TripsyColors.activeGreen.withValues(alpha: 0.45),
                              blurRadius: 20,
                            )
                          ],
                          child: const Text(
                            'LIKE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: TripsyColors.activeGreen,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // "PASS" Stamp indicator overlay
                  if (_dragOffset.dx < -20)
                    Positioned(
                      top: 40,
                      right: 30,
                      child: Transform.rotate(
                        angle: 0.2,
                        child: GlassContainer(
                          borderRadius: 16,
                          opacity: 0.1,
                          borderSide: const BorderSide(color: TripsyColors.errorRed, width: 3.5),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shadows: [
                            BoxShadow(
                              color: TripsyColors.errorRed.withValues(alpha: 0.45),
                              blurRadius: 20,
                            )
                          ],
                          child: const Text(
                            'NOPE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: TripsyColors.errorRed,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),

              // Glass Profile Details Info Panel
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: GlassContainer(
                  borderRadius: 24,
                  opacity: 0.08,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name & Verification Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${profile.fullName}, ${DateTime.now().year - profile.createdAt.year + 23}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (profile.isVerified)
                            const Icon(
                              Icons.verified_rounded,
                              color: TripsyColors.oceanTeal,
                              size: 22,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Preferences and distance
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 14, color: TripsyColors.peachBurn),
                          const SizedBox(width: 4),
                          Text(
                            profile.destinationPreferences.isNotEmpty
                                ? 'Heading to: ${profile.destinationPreferences.first}'
                                : 'Exploring nearby',
                            style: const TextStyle(fontSize: 13, color: TripsyColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Travel style details pills
                      Row(
                        children: [
                          _buildPill(
                            icon: Icons.account_balance_wallet_outlined,
                            label: profile.budgetStyle.toUpperCase(),
                            color: TripsyColors.sunsetOrange,
                          ),
                          const SizedBox(width: 8),
                          _buildPill(
                            icon: Icons.translate_rounded,
                            label: profile.languages.isNotEmpty ? profile.languages.first : 'English',
                            color: TripsyColors.oceanTeal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Bio text preview
                      Text(
                        profile.bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
}

  Widget _buildPill({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Profile topProfile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass Button (X)
          _buildActionButton(
            icon: Icons.close_rounded,
            color: TripsyColors.errorRed,
            size: 56,
            onPressed: () => _performSwipe(topProfile, 'pass'),
          ),

          // Superlike Button (Star)
          _buildActionButton(
            icon: Icons.star_rounded,
            color: TripsyColors.skyBlue,
            size: 48,
            onPressed: () => _performSwipe(topProfile, 'super'),
          ),

          // Like Button (Heart)
          _buildActionButton(
            icon: Icons.favorite_rounded,
            color: TripsyColors.activeGreen,
            size: 56,
            onPressed: () => _performSwipe(topProfile, 'like'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: GlassContainer(
        width: size,
        height: size,
        borderRadius: size / 2,
        opacity: 0.05,
        padding: EdgeInsets.zero,
        borderSide: BorderSide(color: color.withValues(alpha: 0.35), width: 1.5),
        shadows: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }

  // --- MATCH CELEBRATION MODAL OVERLAY ---
  Widget _buildMatchOverlay(String matchedUserId) {
    final matchedProfile = ref.read(swipeDeckProvider).profiles.firstWhere(
          (p) => p.id == matchedUserId,
          orElse: () => ref.read(swipeDeckProvider).profiles.isNotEmpty
              ? ref.read(swipeDeckProvider).profiles.first
              : Profile(
                  id: matchedUserId,
                  username: 'lena',
                  fullName: 'Elena Rostova',
                  avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&auto=format&fit=crop',
                  images: [],
                  bio: '',
                  gender: '',
                  travelInterests: [],
                  destinationPreferences: [],
                  budgetStyle: '',
                  languages: [],
                  personalityTags: [],
                  isVerified: false,
                  latitude: 0,
                  longitude: 0,
                  socialLinks: {},
                  createdAt: DateTime.now(),
                ),
        );

    final currentUser = ref.watch(currentUserProvider).value ??
        Profile(
          id: 'me',
          username: 'me',
          fullName: 'Me',
          avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=600&auto=format&fit=crop',
          images: [],
          bio: '',
          gender: '',
          travelInterests: [],
          destinationPreferences: [],
          budgetStyle: '',
          languages: [],
          personalityTags: [],
          isVerified: false,
          latitude: 0,
          longitude: 0,
          socialLinks: {},
          createdAt: DateTime.now(),
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Frosted Glass Screen Overlay
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                color: Colors.black.withValues(alpha: 0.65),
              ),
            ),
          ),

          // Confetti particles drawing
          CustomPaint(
            painter: ConfettiPainter(particles: _particles),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => TripsyColors.sunsetGradient.createShader(bounds),
                  child: const Text(
                    'It\'s a Match!',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You and ${matchedProfile.fullName} want to explore together.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: TripsyColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 60),

                // Profiles circles intersecting with elegant overlapping
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background glow behind avatars
                    Container(
                      width: 220,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: TripsyColors.sunsetOrange.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: TripsyColors.oceanTeal.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Current User Avatar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: TripsyColors.sunsetOrange, width: 3.5),
                            boxShadow: [
                              BoxShadow(
                                color: TripsyColors.sunsetOrange.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(-4, 4),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(currentUser.avatarUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: -20), // Handcrafted overlap!
                        // Matched User Avatar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: TripsyColors.oceanTeal, width: 3.5),
                            boxShadow: [
                              BoxShadow(
                                color: TripsyColors.oceanTeal.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(4, 4),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(matchedProfile.avatarUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 80),

                // Send Wave Button
                GestureDetector(
                  onTap: () {
                    // Close popup and route directly to chat room
                    ref.read(swipeDeckProvider.notifier).clearMatch();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          chatId: 'chat_${matchedProfile.id}',
                          title: matchedProfile.fullName,
                          avatarUrl: matchedProfile.avatarUrl,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: TripsyColors.sunsetGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: TripsyColors.sunsetOrange.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Send a Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Keep Swiping Button
                TextButton(
                  onPressed: () {
                    ref.read(swipeDeckProvider.notifier).clearMatch();
                  },
                  child: const Text(
                    'Keep Swiping',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: TripsyColors.textSecondary,
                    ),
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

// Particle class for Match Popup animation
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double radius;
  double alpha = 1.0;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.radius,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.35; // Gravity
    vx *= 0.98; // Drag
    alpha = max(0.0, alpha - 0.008); // Fade out
  }
}

// Custom Painter for drawing confetti particles
class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      if (p.alpha <= 0.0) continue;
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
