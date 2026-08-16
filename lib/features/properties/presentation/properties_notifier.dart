import 'package:flutter/foundation.dart';
import 'package:trvlez_mobile/features/properties/data/properties_repository.dart';
import 'package:trvlez_mobile/features/properties/domain/property.dart';

class PropertiesNotifier extends ChangeNotifier {
  final PropertiesRepository repository;

  PropertiesNotifier({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<Property> _properties = [];
  List<Property> get properties => _properties;

  Future<void> fetchProperties() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _properties = await repository.getProperties();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _properties = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
