import 'dart:ui';
import 'package:flutter/material.dart';
import '../../shared/widgets/fade_through_route.dart';
import '../../shared/widgets/app_shell.dart';

enum AuthMode { login, signup }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  AuthMode _mode = AuthMode.login;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _rotateController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Slow continuous rotation for the outer dashed ring.
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // Gentle breathing pulse for the inner rings.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _continueToApp() {
  
  Navigator.of(context).pushReplacement(
  FadeThroughRoute(page: const AppShell()),
);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final mutedColor = Theme.of(context).textTheme.bodySmall?.color;
    final isLogin = _mode == AuthMode.login;
    final cardColor = Theme.of(context).cardTheme.color!;

    return Scaffold(
      body: Column(
        children: [
          // ---------- Animated header ----------
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Container(
              color: cardColor,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating dashed ring
                  AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateController.value * 6.28319, // 2π
                        child: child,
                      );
                    },
                    child: _RingOutline(size: 190, color: accent.withOpacity(0.3), dashed: true),
                  ),

                  // Two pulsing inner rings, offset from each other
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1 + (_pulseController.value * 0.08);
                      final opacity = 0.15 + (_pulseController.value * 0.2);
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(opacity: opacity, child: child),
                      );
                    },
                    child: _RingOutline(size: 180, color: accent),
                  ),
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final value = (1 - _pulseController.value); // offset rhythm
                      final scale = 1 + (value * 0.1);
                      final opacity = 0.25 + (value * 0.25);
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(opacity: opacity, child: child),
                      );
                    },
                    child: _RingOutline(size: 130, color: accent),
                  ),

                  // Soft filled center glow
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withOpacity(0.12),
                    ),
                  ),

                  // Logo mark
                  Positioned(
                    top: 90,
                    child: Icon(Icons.shield_outlined, size: 52, color: accent),
                  ),

                  // Wordmark — Q in accent color, rest neutral
                  Positioned(
                    bottom: 24,
                    child: Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                        children: [
                          TextSpan(text: 'Q', style: TextStyle(color: accent)),
                          const TextSpan(text: 'uestify'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- Glassmorphic form card ----------
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.55),
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.08)),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isLogin ? 'Welcome back' : 'Create your account',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isLogin
                                ? 'Sign in to continue your progress.'
                                : 'Start turning your goals into quests.',
                            style: TextStyle(color: mutedColor, fontSize: 13),
                          ),
                          const SizedBox(height: 24),

                          // Login / Signup toggle
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                _ToggleTab(
                                  label: 'Login',
                                  isActive: isLogin,
                                  accent: accent,
                                  onTap: () => setState(() => _mode = AuthMode.login),
                                ),
                                _ToggleTab(
                                  label: 'Sign up',
                                  isActive: !isLogin,
                                  accent: accent,
                                  onTap: () => setState(() => _mode = AuthMode.signup),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          _GlassField(label: 'Email', hint: 'you@example.com', controller: _emailController),
                          const SizedBox(height: 12),
                          _GlassField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                size: 18,
                                color: mutedColor,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),

                          if (isLogin) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text('Forgot password?', style: TextStyle(color: mutedColor, fontSize: 12)),
                              ),
                            ),
                          ],

                          const SizedBox(height: 18),

                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _continueToApp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                              ),
                              child: Text(
                                isLogin ? 'Log in' : 'Create account',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('or continue with', style: TextStyle(color: mutedColor, fontSize: 12)),
                              ),
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: _AltAuthButton(
                                  // TODO: swap for the official multi-color Google "G" asset
                                  // before shipping — required by Google's brand guidelines.
                                  leading: const Text('G', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                  label: 'Google',
                                  onTap: _continueToApp,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _AltAuthButton(
                                  leading: const Icon(Icons.phone_outlined, size: 16),
                                  label: 'Phone',
                                  onTap: _continueToApp,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingOutline extends StatelessWidget {
  final double size;
  final Color color;
  final bool dashed;

  const _RingOutline({required this.size, required this.color, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color accent;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isActive
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;

  const _GlassField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

class _AltAuthButton extends StatelessWidget {
  final Widget leading;
  final String label;
  final VoidCallback onTap;

  const _AltAuthButton({required this.leading, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}