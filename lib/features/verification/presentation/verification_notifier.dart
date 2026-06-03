import 'dart:io';

import 'package:flutter/foundation.dart';
import '../../../core/network/api_exception.dart';
import '../data/verification_repository.dart';

enum VerificationStatus {
  idle,
  uploading,
  success,
  error,
}

class VerificationNotifier extends ChangeNotifier {
  final VerificationRepository _repository;

  VerificationNotifier({VerificationRepository? repository})
      : _repository = repository ?? VerificationRepository();

  File? _capturedImage;
  File? _capturedVideo;
  VerificationStatus _status = VerificationStatus.idle;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  File? get capturedImage => _capturedImage;
  File? get capturedVideo => _capturedVideo;
  VerificationStatus get status => _status;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;

  void setImage(File image) {
    _capturedImage = image;
    _status = VerificationStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void clearImage() {
    _capturedImage = null;
    _status = VerificationStatus.idle;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  void setVideo(File video) {
    _capturedVideo = video;
    _status = VerificationStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void clearVideo() {
    _capturedVideo = null;
    _status = VerificationStatus.idle;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  Future<void> uploadPassport() async {
    if (_capturedImage == null) return;

    _status = VerificationStatus.uploading;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.uploadPassport(
        _capturedImage!,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );
      
      _status = VerificationStatus.success;
      notifyListeners();
    } on ApiException catch (e) {
      _status = VerificationStatus.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _status = VerificationStatus.error;
      _errorMessage = 'Upload failed: $e';
      notifyListeners();
    }
  }

  Future<void> uploadSelfie() async {
    if (_capturedVideo == null) return;

    _status = VerificationStatus.uploading;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.uploadSelfie(
        _capturedVideo!,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );
      
      await _repository.submitVerification();
      
      _status = VerificationStatus.success;
      notifyListeners();
    } on ApiException catch (e) {
      _status = VerificationStatus.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _status = VerificationStatus.error;
      _errorMessage = 'Upload failed: $e';
      notifyListeners();
    }
  }
}
