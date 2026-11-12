import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trvlez_mobile/app/router/routes.dart';
import 'package:trvlez_mobile/app/theme/app_theme.dart';
import 'package:trvlez_mobile/app/theme/icons/app_icons.dart';
import 'package:trvlez_mobile/app/theme/theme_extensions.dart';
import 'package:trvlez_mobile/core/auth/auth_notifier.dart';
import 'package:trvlez_mobile/core/providers/shared_providers.dart';
import 'package:trvlez_mobile/core/widgets/app_pinned_header.dart';
import 'package:trvlez_mobile/core/widgets/findr_card.dart';
import 'package:trvlez_mobile/core/widgets/join_findr_sheet.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/check_in_banner.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/home_location_row.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/home_section_header.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/home_wordmark_row.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/location_picker_sheet.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/next_stay_row.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/notifications_sheet.dart';
import 'package:trvlez_mobile/features/home/presentation/widgets/service_grid.dart';
import 'package:trvlez_mobile/features/reservations/domain/entities/reservation.dart';

/// The central Home Hub screen displaying wordmark, location, service cards,
/// Findr loyalty card, and next stay previews.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedLocation = 'Edinburgh, UK';
  final Set<String> _readNotifIds = {};

  List<NotificationItem> _getNotifications({
    Reservation? nextStay,
    required bool isVerified,
  }) {
    return [
      if (nextStay != null) ...[
        NotificationItem(
          id: 'notif-stay-${nextStay.id}',
          title: 'Booking confirmed',
          body:
              '${nextStay.propertySummary.name} · ${DateFormat('d MMM').format(nextStay.checkInDate)}',
          timeAgo: 'Recent',
          icon: AppIcons.check,
          isUnread: !_readNotifIds.contains('notif-stay-${nextStay.id}'),
        ),
        NotificationItem(
          id: 'notif-checkin-${nextStay.id}',
          title: 'Check-in open',
          body:
              'Online check-in is now ready for ${nextStay.propertySummary.name}',
          timeAgo: 'Recent',
          icon: AppIcons.doorEnter,
          isUnread: !_readNotifIds.contains('notif-checkin-${nextStay.id}'),
        ),
      ],
      if (isVerified)
        NotificationItem(
          id: 'notif-verify',
          title: 'Identity verified',
          body: 'Your passport and biometrics are approved',
          timeAgo: 'Recent',
          icon: AppIcons.rosetteDiscountCheck,
          isUnread: !_readNotifIds.contains('notif-verify'),
        ),
    ];
  }

  void _onBellTap(List<NotificationItem> notifications) {
    NotificationsSheet.show(
      context,
      items: notifications,
      onClearAll: () {
        setState(() {
          for (final n in notifications) {
            _readNotifIds.add(n.id);
          }
        });
      },
    );
  }

  void _onLocationTap() {
    LocationPickerSheet.show(
      context,
      currentLocation: _selectedLocation,
      onLocationSelected: (city) {
        setState(() => _selectedLocation = city);
      },
    );
  }

  String _greetingText(String? name) {
    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12
        ? 'Good morning'
        : (hour < 17 ? 'Good afternoon' : 'Good evening');
    if (name != null && name.trim().isNotEmpty) {
      final firstName = name.trim().split(' ').first;
      return '$timeGreeting, $firstName';
    }
    return timeGreeting;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final space = context.space;
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDarkMode =
        currentThemeMode == ThemeMode.dark ||
        (currentThemeMode == ThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);

    final verificationState = ref.watch(travelerVerificationStateProvider);
    final isVerified = verificationState.isVerified;

    final reservationsState = ref.watch(reservationListProvider);
    final allReservations = reservationsState.valueOrNull ?? [];
    final upcomingReservations =
        allReservations.where((r) => r.status.isUpcoming).toList()
          ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));
    final nextStay = upcomingReservations.isNotEmpty
        ? upcomingReservations.first
        : null;

    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final displayName = profile?.displayName?.trim();
    final travelerName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : nextStay?.guestName;

    final notifications = _getNotifications(
      nextStay: nextStay,
      isVerified: isVerified,
    );
    final unreadCount = notifications.where((n) => n.isUnread).length;

    final findrPortfolio = ref.watch(liveFindrPortfolioProvider);
    final finderSummary = ref.watch(finderNotifierProvider).valueOrNull;
    final isFinderActive = finderSummary?.finder != null
        ? finderSummary!.finder!.isActive
        : findrPortfolio.joined;

    final findrCardState = !isVerified
        ? (verificationState.isProcessing
              ? FindrState.processing
              : FindrState.locked)
        : (isFinderActive ? FindrState.active : FindrState.notJoined);

    return Scaffold(
      backgroundColor: colors.page,
      body: Column(
        children: [
          // ── Pinned Header ──────────────────────────────────────────────
          AppPinnedHeader(
            paddingBottom: space.insetCard.bottom,
            horizontalPadding: space.insetCardComfortable.left,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                HomeWordmarkRow(
                  unreadCount: unreadCount,
                  onBellTap: () => _onBellTap(notifications),
                  isDarkMode: isDarkMode,
                  onThemeToggle: () =>
                      ref.read(themeModeProvider.notifier).toggleTheme(),
                ),
                SizedBox(height: space.stackItem + space.stackText),
                HomeLocationRow(
                  location: _selectedLocation,
                  onTap: _onLocationTap,
                ),
                SizedBox(height: space.stackTight),
                Text(
                  _greetingText(travelerName),
                  style: context.text.headlineMedium?.copyWith(
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: space.stackText),
                Text(
                  isVerified
                      ? 'ID verified — book without re-checking'
                      : (verificationState.isProcessing
                            ? 'Verification in review · usually under a minute'
                            : 'Verify once, book without re-checking'),
                  style: context.text.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable Hub Content ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: space.insetCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Check-in banner when an upcoming stay is ready
                  if (nextStay != null) ...[
                    CheckInBanner(
                      title: 'Check in for ${nextStay.propertySummary.name}',
                      subtitle: 'Open now · takes 2 minutes',
                      onTap: () {
                        if (nextStay.status == ReservationStatus.checkedIn) {
                          context.push(AppRoutes.checkInPassPath(nextStay.id));
                        } else {
                          context.push(AppRoutes.checkInStepsPath(nextStay.id));
                        }
                      },
                    ),
                    SizedBox(height: space.stackSection),
                  ],

                  // ── Services Section ───────────────────────────────────
                  const HomeSectionHeader(title: 'Services'),
                  SizedBox(height: space.stackFormField),
                  ServiceGrid(
                    cards: [
                      ServiceCard(
                        icon: AppIcons.building,
                        title: 'Stays',
                        subtitle: 'Hotels, resorts, villas',
                        onTap: () => context.push(AppRoutes.ezStays),
                      ),
                      const ServiceCard(
                        icon: AppIcons.wallet,
                        title: 'Money',
                        subtitle: 'Exchange and spend',
                        soon: true,
                      ),
                      const ServiceCard(
                        icon: AppIcons.shoppingBag,
                        title: 'Shop',
                        subtitle: 'Duty free and local',
                        soon: true,
                      ),
                      const ServiceCard(
                        icon: AppIcons.messageCircle,
                        title: 'Chat',
                        subtitle: 'Talk to your host',
                        soon: true,
                      ),
                    ],
                  ),
                  SizedBox(height: space.stackSection),

                  // ── Earn With Us Section ───────────────────────────────
                  HomeSectionHeader(
                    title: 'Earn with us',
                    action: findrCardState == FindrState.active ? 'Open' : null,
                    onAction: () => context.push(AppRoutes.findr),
                  ),
                  SizedBox(height: space.stackItem),
                  FindrCard(
                    state: findrCardState,
                    earned: findrPortfolio.earned,
                    joined: findrPortfolio.joinedCount,
                    inReview: findrPortfolio.inReviewCount,
                    due: findrPortfolio.dueAmount,
                    dueDate: findrPortfolio.dueDate,
                    onCta: () {
                      if (findrCardState == FindrState.locked ||
                          findrCardState == FindrState.processing) {
                        if (verificationState.isProcessing ||
                            verificationState.isFailed) {
                          context.push(AppRoutes.verificationStatus);
                        } else {
                          context.push(AppRoutes.verificationLanding);
                        }
                      } else if (findrCardState == FindrState.notJoined) {
                        showJoinFindrSheet(context).then((joined) {
                          if (joined == true) {
                            ref
                                .read(findrPortfolioProvider.notifier)
                                .joinFindr();
                            ref.read(finderNotifierProvider.notifier).refresh();
                          }
                        });
                      } else {
                        context.push(AppRoutes.findr);
                      }
                    },
                  ),
                  SizedBox(height: space.stackSection),

                  // ── Next Stay Section ──────────────────────────────────
                  if (nextStay != null) ...[
                    HomeSectionHeader(
                      title: 'Your next stay',
                      action: 'View',
                      onAction: () =>
                          context.push('/reservations/${nextStay.id}'),
                    ),
                    SizedBox(height: space.stackItem),
                    NextStayRow(
                      title: nextStay.propertySummary.name,
                      detail:
                          '${DateFormat('d MMM').format(nextStay.checkInDate)}–${DateFormat('d MMM').format(nextStay.checkOutDate)} · ${nextStay.propertySummary.city ?? 'Stay'}',
                      badge:
                          '${nextStay.checkOutDate.difference(nextStay.checkInDate).inDays} nights',
                      imageUrl: nextStay.propertySummary.heroImageUrl,
                      onTap: () => context.push('/reservations/${nextStay.id}'),
                    ),
                    SizedBox(height: space.stackHero),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
