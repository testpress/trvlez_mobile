import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/nfc_passport_service.dart';
import '../domain/nfc_error.dart';
import '../domain/nfc_read_progress.dart';
import 'verification_notifier.dart';

/// Active scanning screen that handles the real-time interaction with the NFC service.
class NfcScanScreen extends StatefulWidget {
  final VerificationNotifier notifier;
  final NfcPassportService nfcService;

  const NfcScanScreen({
    super.key,
    required this.notifier,
    required this.nfcService,
  });

  @override
  State<NfcScanScreen> createState() => _NfcScanScreenState();
}

class _NfcScanScreenState extends State<NfcScanScreen> with SingleTickerProviderStateMixin {
  NfcReadProgress? _currentProgress;
  NfcError? _error;
  bool _isCheckingAvailability = true;
  bool _isNfcAvailable = false;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
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
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkNfcAndStart() async {
    final available = await widget.nfcService.isNfcAvailable();
    
    if (!mounted) return;
    
    setState(() {
      _isCheckingAvailability = false;
      _isNfcAvailable = available;
    });

    if (available) {
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
      // In a real app, these values should come from the OCR extraction.
      // Assuming VerificationNotifier holds the extracted MRZ info or we fall back.
      // For this implementation, we simulate extraction or expect the notifier to provide it.
      final docNumber = widget.notifier.extractedDocumentNumber ?? '';
      final dob = widget.notifier.extractedDateOfBirth ?? DateTime(1990, 1, 1);
      final doe = widget.notifier.extractedDateOfExpiry ?? DateTime(2030, 1, 1);
      
      if (docNumber.isEmpty) {
        throw const NfcError(
          type: NfcErrorType.invalidMrzData, 
          message: 'Could not extract passport number from photo.',
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
      
      widget.notifier.setNfcResult(result);
      context.pushReplacement('/verification/nfc-result');
      
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
    widget.notifier.skipNfc();
    widget.notifier.submitVerification();
    context.go('/verification/status');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Scanning Passport'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // Prevent backing out during active scan easily
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              // Should potentially cancel active scan if possible, then pop
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
              else if (!_isNfcAvailable)
                _buildNfcUnavailableView(theme)
              else if (_error != null)
                _buildErrorView(theme)
              else
                _buildScanningView(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningView(ThemeData theme) {
    final progress = _currentProgress?.percentage ?? 0.0;
    final description = _currentProgress?.description ?? 'Preparing...';

    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(50),
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.contactless_rounded,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 48),
        Text(
          description,
          style: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        LinearProgressIndicator(
          value: progress > 0 ? progress : null, // Null means indeterminate
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 16),
        Text(
          'Keep your phone steady against the passport',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withAlpha(150),
          ),
        ),
        // Platform specific guide
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Platform.isIOS ? Icons.phone_iphone_rounded : Icons.android_rounded,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Platform.isIOS 
                    ? 'Rest the top edge of your iPhone on the inside back cover of the passport.'
                    : 'Place the middle/top of your phone flat against the passport data page.',
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 80,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 24),
        Text(
          'Scan Failed',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _error!.message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withAlpha(180),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        if (_error!.isRetryable)
          FilledButton.icon(
            onPressed: _startScan,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          )
        else if (_error!.type == NfcErrorType.authenticationFailed)
          FilledButton.icon(
            onPressed: () {
              // Go back to OCR to re-capture MRZ
              context.go('/verification/passport-capture');
            },
            icon: const Icon(Icons.document_scanner_rounded),
            label: const Text('Re-scan Passport Photo'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _skipNfc,
          child: const Text('Skip NFC Verification'),
        ),
      ],
    );
  }

  Widget _buildNfcUnavailableView(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.nfc_rounded,
          size: 80,
          color: theme.colorScheme.onSurface.withAlpha(100),
        ),
        const SizedBox(height: 24),
        Text(
          'NFC Not Available',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your device either does not support NFC or it is currently disabled. You can continue verification without NFC.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withAlpha(180),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        FilledButton(
          onPressed: _skipNfc,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text('Continue Without NFC'),
        ),
      ],
    );
  }
}
