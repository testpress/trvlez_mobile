import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/app/theme/tokens/app_colors.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/verification_banner.dart';
import 'package:trvlez_mobile/features/profile/presentation/providers/profile_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';

/// The primary landing screen for all authenticated travelers.
///
/// Always shown after login regardless of onboarding state. Displays a
/// context-aware verification banner that guides users through profile
/// completion, document upload, or shows verification progress.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> handleRefresh() async {
    ref.invalidate(currentProfileProvider);
    ref.invalidate(verificationStatusProvider);
    await ref.read(authNotifierProvider.notifier).refreshVerificationState();
  }

  void onBannerTap(TravelerVerificationState state) {
    if (state.needsOnboarding) {
      // Pre-submission: go to onboarding stepper to complete steps
      context.push(AppRoutes.onboarding);
    } else {
      // Post-submission (submitted, failed): go to status screen
      context.push(AppRoutes.verificationStatus);
    }
  }

  void onFeatureTap(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName — coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final profileAsync = ref.watch(currentProfileProvider);
    final profile = profileAsync.value;
    final verificationStatusAsync = ref.watch(verificationStatusProvider);
    final verificationStatus = verificationStatusAsync.value;

    TravelerVerificationState verificationState =
        profile?.verificationState ?? TravelerVerificationState.profilePending;
    if (verificationState == TravelerVerificationState.submitted &&
        verificationStatus?.isFailed == true) {
      verificationState = TravelerVerificationState.failed;
    }

    final shouldShowBanner = verificationState.shouldShowBanner;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                text: 'Trvl',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: 'Ez',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile Options',
            onSelected: (value) async {
              if (value == 'theme') {
                await ref.read(themeModeProvider.notifier).toggleTheme();
              }
            },
            itemBuilder: (context) {
              final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
              return [
                PopupMenuItem(
                  value: 'theme',
                  child: Row(
                    children: [
                      Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(isDark ? 'Light Mode' : 'Dark Mode'),
                    ],
                  ),
                ),
              ];
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                ref.read(authNotifierProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: profileAsync.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // ── Verification Banner ─────────────────────────
                    if (shouldShowBanner)
                      VerificationBanner(
                        state: verificationState,
                        onActionTap: () => onBannerTap(verificationState),
                      ),
                    const SizedBox(height: 24),
                    // ── Welcome Section ──────────────────────────────
                    WelcomeSection(isVerified: verificationState.isVerified),
                    const SizedBox(height: 32),
                    // ── Feature Grid ────────────────────────────────
                    FeatureGrid(
                      isVerified: verificationState.isVerified,
                      onFeatureTap: onFeatureTap,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Welcome Section ──────────────────────────────────────────────────────

class WelcomeSection extends StatelessWidget {
  final bool isVerified;

  const WelcomeSection({super.key, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isVerified ? 'Ready to explore!' : 'Welcome to TrvlEz!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isVerified
                ? 'Your identity is verified. Start planning your next adventure.'
                : 'Your next adventure awaits. Complete your setup to unlock all features.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(160),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feature Grid ─────────────────────────────────────────────────────────

class FeatureGrid extends StatelessWidget {
  final bool isVerified;
  final void Function(String featureName) onFeatureTap;

  const FeatureGrid({
    super.key,
    required this.isVerified,
    required this.onFeatureTap,
  });

  @override
  Widget build(BuildContext context) {
    final features = const [
      FeatureItem(
        icon: Icons.explore_rounded,
        label: 'Explore',
        subtitle: 'Discover destinations',
        gradientColors: AppColors.exploreGradient,
      ),
      FeatureItem(
        icon: Icons.flight_takeoff_rounded,
        label: 'My Trips',
        subtitle: 'View bookings',
        gradientColors: AppColors.tripsGradient,
      ),
      FeatureItem(
        icon: Icons.local_offer_rounded,
        label: 'Deals',
        subtitle: 'Exclusive offers',
        gradientColors: AppColors.dealsGradient,
      ),
      FeatureItem(
        icon: Icons.support_agent_rounded,
        label: 'Support',
        subtitle: 'Get help',
        gradientColors: AppColors.supportGradient,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.15,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return FeatureCard(
            feature: feature,
            onTap: () => onFeatureTap(feature.label),
          );
        },
      ),
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradientColors;

  const FeatureItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradientColors,
  });
}

class FeatureCard extends StatelessWidget {
  final FeatureItem feature;
  final VoidCallback onTap;

  const FeatureCard({super.key, required this.feature, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(80),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: feature.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(feature.icon, color: Colors.white, size: 26),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.label,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    feature.subtitle,
                    style: GoogleFonts.cabin(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(130),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
