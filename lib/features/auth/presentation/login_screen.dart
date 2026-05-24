import 'package:flutter/material.dart';
import 'package:tripsy/core/theme/colors.dart';
import 'package:tripsy/core/widgets/glass_container.dart';
import 'package:tripsy/core/widgets/aurora_background.dart';
import 'package:tripsy/core/services/supabase_service.dart';
import 'package:tripsy/features/home/presentation/home_navigation_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUp) {
        await SupabaseService.instance.signUpWithEmail(email, password);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Welcome to Tripsy.')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeNavigationScaffold()),
          );
        }
      } else {
        await SupabaseService.instance.signInWithEmail(email, password);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeNavigationScaffold()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auth Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AuroraBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Travel Imagery blended with Aurora
            Image.network(
              'https://images.unsplash.com/photo-1527631746610-bca00a040d60?w=600&auto=format&fit=crop',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.65),
              colorBlendMode: BlendMode.darken,
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Handcrafted Logo title
                    Row(
                      children: [
                        GlassContainer(
                          width: 44,
                          height: 44,
                          borderRadius: 14,
                          opacity: 0.08,
                          padding: EdgeInsets.zero,
                          borderSide: const BorderSide(
                            color: TripsyColors.sunsetOrange,
                            width: 1.5,
                          ),
                          shadows: [
                            BoxShadow(
                              color: TripsyColors.sunsetOrange.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          child: const Center(
                            child: Icon(
                              Icons.explore_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Tripsy',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _isSignUp ? 'Create Account' : 'Let\'s Connect',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Sign up to discover and match with travel partners worldwide.'
                          : 'Sign in to match with travel companions around the globe.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: TripsyColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Login Form Glass Panel
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: GlassContainer(
                            padding: const EdgeInsets.all(26.0),
                            borderRadius: 32,
                            opacity: 0.05,
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.06),
                              width: 1.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Email Login Form
                                _buildTextField(
                                  controller: _emailController,
                                  hintText: 'Enter your email',
                                  icon: Icons.mail_outline_rounded,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _passwordController,
                                  hintText: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                ),

                                // Main Action Button
                                const SizedBox(height: 24),
                                _buildGradientButton(
                                  onPressed: _handleEmailAuth,
                                  label: _isLoading ? 'Loading...' : (_isSignUp ? 'Sign Up' : 'Sign In'),
                                ),

                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        'or connect with',
                                        style: TextStyle(fontSize: 12, color: TripsyColors.textMuted, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Google Sign in
                                GestureDetector(
                                  onTap: _handleEmailAuth,
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.06),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                          height: 20,
                                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Continue with Google',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),
                                // Sign Up Toggle Option
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isSignUp = !_isSignUp;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 14, color: TripsyColors.textSecondary),
                                      children: [
                                        TextSpan(
                                          text: _isSignUp ? 'Already have an account? ' : 'Don\'t have an account? ',
                                        ),
                                        TextSpan(
                                          text: _isSignUp ? 'Sign In' : 'Sign Up',
                                          style: const TextStyle(
                                            color: TripsyColors.sunsetOrange,
                                            fontWeight: FontWeight.w800,
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
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: TripsyColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: TripsyColors.textMuted, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: TripsyColors.sunsetOrange,
            width: 1.5,
          ),
        ),
        fillColor: Colors.white.withValues(alpha: 0.03),
        filled: true,
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: TripsyColors.sunsetGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TripsyColors.sunsetOrange.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
