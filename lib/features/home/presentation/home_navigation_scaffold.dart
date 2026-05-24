import 'package:flutter/material.dart';
import 'package:tripsy/core/theme/colors.dart';
import 'package:tripsy/core/widgets/glass_container.dart';
import 'package:tripsy/features/home/presentation/swipe_deck_screen.dart';
import 'package:tripsy/features/discover/presentation/discover_feed_screen.dart';
import 'package:tripsy/features/trips/presentation/trip_rooms_screen.dart';
import 'package:tripsy/features/chat/presentation/chat_screens.dart';
import 'package:tripsy/features/profile/presentation/profile_screens.dart';

class HomeNavigationScaffold extends StatefulWidget {
  const HomeNavigationScaffold({super.key});

  @override
  State<HomeNavigationScaffold> createState() => _HomeNavigationScaffoldState();
}

class _HomeNavigationScaffoldState extends State<HomeNavigationScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SwipeDeckScreen(),
    const DiscoverFeedScreen(),
    const TripRoomsScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Crucial for floating glass tab bar translucency
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildFloatingBottomBar(),
    );
  }

  Widget _buildFloatingBottomBar() {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: GlassContainer(
          height: 68,
          borderRadius: 28,
          opacity: 0.08,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.style_rounded, 'Match'),
              _buildNavItem(1, Icons.explore_rounded, 'Discover'),
              _buildNavItem(2, Icons.group_work_rounded, 'Trips'),
              _buildNavItem(3, Icons.chat_bubble_rounded, 'Chats'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        tween: Tween<double>(begin: 0.9, end: isSelected ? 1.15 : 0.95),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => isSelected
                      ? TripsyColors.sunsetGradient.createShader(bounds)
                      : const LinearGradient(colors: [TripsyColors.textMuted, TripsyColors.textMuted])
                          .createShader(bounds),
                  child: Icon(
                    icon,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? TripsyColors.sunsetOrange : TripsyColors.textMuted,
                  ),
                  child: Text(label),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
