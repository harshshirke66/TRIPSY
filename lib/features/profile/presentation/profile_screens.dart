import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsy/core/models/profile_model.dart';
import 'package:tripsy/core/theme/colors.dart';
import 'package:tripsy/core/widgets/glass_container.dart';
import 'package:tripsy/core/widgets/aurora_background.dart';
import 'package:tripsy/core/providers/providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: userState.when(
          data: (user) => _buildProfileContent(user),
          loading: () => const Center(child: CircularProgressIndicator(color: TripsyColors.sunsetOrange)),
          error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
        ),
      ),
    );
  }

  Widget _buildProfileContent(Profile user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: 60),
          _buildAvatarHeader(user),
          const SizedBox(height: 24),
          _buildPremiumBanner(),
          const SizedBox(height: 24),
          _buildStatsRow(user),
          const SizedBox(height: 24),
          _buildBioSection(user),
          const SizedBox(height: 24),
          _buildInterestsSection(user),
          const SizedBox(height: 24),
          _buildPhotoGrid(user),
        ],
      ),
    );
  }

  Widget _buildAvatarHeader(Profile user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: TripsyColors.sunsetGradient,
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
            ),
            if (user.isVerified)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: TripsyColors.deepSpace,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TripsyColors.oceanTeal,
                      blurRadius: 10,
                      spreadRadius: -2,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: TripsyColors.oceanTeal,
                  size: 26,
                ),
              )
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@${user.username}',
          style: const TextStyle(
            fontSize: 14,
            color: TripsyColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionIcon(Icons.edit_rounded, 'Edit Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
              );
            }),
            const SizedBox(width: 12),
            _buildActionIcon(Icons.settings_rounded, 'Settings', () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 16,
        opacity: 0.03,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onTap: () => _showPremiumDrawer(context),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                TripsyColors.peachBurn,
                TripsyColors.skyBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: TripsyColors.peachBurn.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.star_rounded, size: 36, color: Colors.white),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to Tripsy Gold',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Unlimited swipes, passport travel, and more!',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(Profile user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        borderRadius: 20,
        opacity: 0.03,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('12', 'Trips Joined'),
            Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.08)),
            _buildStatItem('34', 'New Matches'),
            Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.08)),
            _buildStatItem(user.budgetStyle.toUpperCase(), 'Budget Style'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: TripsyColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBioSection(Profile user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Me',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          GlassContainer(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            borderRadius: 20,
            opacity: 0.02,
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
            child: Text(
              user.bio.isNotEmpty ? user.bio : 'Write something interesting about yourself...',
              style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(Profile user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Travel Interests',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.travelInterests.map((interest) {
              return GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                borderRadius: 12,
                opacity: 0.03,
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                child: Text(
                  '# $interest',
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(Profile user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adventure Gallery',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: user.images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, idx) {
              final rotationAngle = (idx % 3 == 0) ? -0.04 : (idx % 3 == 1 ? 0.03 : -0.02);
              return Transform.rotate(
                angle: rotationAngle,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(user.images[idx], fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPremiumDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumSubscriptionDrawer(),
    );
  }
}

class PremiumSubscriptionDrawer extends StatelessWidget {
  const PremiumSubscriptionDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 32,
      opacity: 0.14,
      padding: const EdgeInsets.all(24),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: const BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.all(Radius.circular(2))),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.stars_rounded, size: 60, color: TripsyColors.peachBurn),
          const SizedBox(height: 16),
          const Text(
            'Unlock Tripsy Gold',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'Premium features to level up your travels',
            style: TextStyle(fontSize: 13, color: TripsyColors.textSecondary),
          ),
          
          // Shimmering premium subscription ticket card
          Container(
            margin: const EdgeInsets.symmetric(vertical: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  TripsyColors.peachBurn,
                  TripsyColors.sunsetOrange,
                  TripsyColors.skyBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: TripsyColors.sunsetOrange.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Column(
              children: [
                Text(
                  'GOLD PASS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '\$9.99 / Month',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Billed monthly. Cancel anytime.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Benefits
          _buildBenefitItem(Icons.all_inclusive_rounded, 'Unlimited Match Swipes', 'Skip the daily limit and connect with everyone.'),
          _buildBenefitItem(Icons.public_rounded, 'Global Passport Location', 'Change your location and match with travelers anywhere.'),
          _buildBenefitItem(Icons.verified_user_rounded, 'Verification Badge Priority', 'Get the gold verified shield and stand out.'),
          
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: TripsyColors.sunsetGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: TripsyColors.sunsetOrange.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Text('Upgrade for \$9.99/mo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: TripsyColors.oceanTeal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: TripsyColors.textSecondary, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  final Profile user;

  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _bioCtrl;
  late TextEditingController _interestsCtrl;
  String _selectedBudget = 'moderate';

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController(text: widget.user.bio);
    _interestsCtrl = TextEditingController(text: widget.user.travelInterests.join(', '));
    _selectedBudget = widget.user.budgetStyle;
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _interestsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AuroraBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bio Description', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              _buildTextField(controller: _bioCtrl, hintText: 'Write something about yourself...', maxLines: 4),
              const SizedBox(height: 20),

              const Text('Travel Interests (comma separated)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              _buildTextField(controller: _interestsCtrl, hintText: 'e.g. hiking, beach, budget, solo'),
              const SizedBox(height: 20),

              const Text('Budget Preferences', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedBudget,
                dropdownColor: TripsyColors.cardBackground,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  fillColor: Colors.white.withValues(alpha: 0.03),
                  filled: true,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: TripsyColors.skyBlue, width: 1.5)),
                ),
                items: const [
                  DropdownMenuItem(value: 'backpacker', child: Text('🎒 Backpacker')),
                  DropdownMenuItem(value: 'budget', child: Text('💵 Budget')),
                  DropdownMenuItem(value: 'moderate', child: Text('💳 Moderate')),
                  DropdownMenuItem(value: 'luxury', child: Text('💎 Luxury')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBudget = val);
                },
              ),
              const SizedBox(height: 32),
              
              GestureDetector(
                onTap: _saveProfile,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: TripsyColors.sunsetGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: TripsyColors.sunsetOrange.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: TripsyColors.textMuted, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: TripsyColors.skyBlue,
            width: 1.5,
          ),
        ),
        fillColor: Colors.white.withValues(alpha: 0.03),
        filled: true,
      ),
    );
  }

  void _saveProfile() {
    final updated = widget.user.copyWith(
      bio: _bioCtrl.text.trim(),
      travelInterests: _interestsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      budgetStyle: _selectedBudget,
    );
    ref.read(currentUserProvider.notifier).updateProfile(updated);
    Navigator.of(context).pop();
  }
}
