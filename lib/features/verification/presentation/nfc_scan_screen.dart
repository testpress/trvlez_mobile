import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trvlez_mobile/app/routes.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_error.dart';
import 'package:trvlez_mobile/features/verification/domain/nfc_read_progress.dart';
import 'package:trvlez_mobile/features/verification/domain/services/nfc_passport_service.dart';
import 'package:trvlez_mobile/features/verification/presentation/providers/verification_providers.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/nfc_error_view.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/nfc_scanning_view.dart';
import 'package:trvlez_mobile/features/verification/presentation/widgets/nfc_status_view.dart';

/// Active scanning screen that handles real-time interaction with the NFC service.
class NfcScanScreen extends ConsumerStatefulWidget {
  final NfcPassportService nfcService;

  const NfcScanScreen({super.key, required this.nfcService});

  @override
  ConsumerState<NfcScanScreen> createState() => _NfcScanScreenState();
}

class _NfcScanScreenState extends ConsumerState<NfcScanScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  NfcReadProgress? _currentProgress;
  NfcError? _error;
  bool _isCheckingAvailability = true;
  NfcDeviceStatus _nfcStatus = NfcDeviceStatus.unsupported;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkNfcAndStart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _nfcStatus == NfcDeviceStatus.disabled) {
      setState(() {
        _isCheckingAvailability = true;
      });
      _checkNfcAndStart();
    }
  }

  Future<void> _checkNfcAndStart() async {
    final status = await widget.nfcService.getNfcStatus();

    if (!mounted) return;

    setState(() {
      _isCheckingAvailability = false;
      _nfcStatus = status;
    });

    if (status == NfcDeviceStatus.available) {
      _startScan();
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _error = null;
      _currentProgress = const NfcReadProgress(
        currentStep: NfcReadStep.connecting,
        percentage: 0.0,
        description: 'Waiting for passport...',
      );
    });

    try {
      final state = ref.read(verificationNotifierProvider);
      final docNumber = state.extractedDocumentNumber ?? '';
      final dob = state.extractedDateOfBirth;
      final doe = state.extractedDateOfExpiry;

      if (docNumber.isEmpty || dob == null || doe == null) {
        throw const NfcError(
          type: NfcErrorType.invalidMrzData,
          message:
              'Passport data is incomplete. Please re-scan your passport photo.',
          userGuidance:
              'Go back and retake the passport photo, ensuring the MRZ '
              'text lines at the bottom of the data page are clearly visible.',
          isRetryable: false,
        );
      }

      final result = await widget.nfcService.readPassport(
        documentNumber: docNumber,
        dateOfBirth: dob,
        dateOfExpiry: doe,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _currentProgress = progress;
            });
          }
        },
      );

      if (!mounted) return;

      ref.read(verificationNotifierProvider.notifier).setNfcResult(result);
      context.pushReplacement(AppRoutes.nfcResult);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (e is NfcError) {
          _error = e;
        } else {
          _error = NfcError.fromException(e);
        }
      });
    }
  }

  void _skipNfc() {
    ref.read(verificationNotifierProvider.notifier).skipNfc();
    ref.read(verificationNotifierProvider.notifier).submitVerificationAsync();
    context.go(AppRoutes.verificationStatus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = _error;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Scanning Passport'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isCheckingAvailability)
                const Center(child: CircularProgressIndicator())
              else if (_nfcStatus == NfcDeviceStatus.disabled)
                NfcStatusView(
                  isDisabled: true,
                  onSkipNfc: _skipNfc,
                )
              else if (_nfcStatus == NfcDeviceStatus.unsupported)
                NfcStatusView(
                  isDisabled: false,
                  onSkipNfc: _skipNfc,
                )
              else if (error != null)
                NfcErrorView(
                  error: error,
                  onRetry: _startScan,
                  onRescanPassport: () => context.go(AppRoutes.passportCapture),
                  onSkipNfc: _skipNfc,
                )
              else
                NfcScanningView(
                  pulseAnimation: _pulseAnimation,
                  currentProgress: _currentProgress,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
