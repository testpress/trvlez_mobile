import 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart';

export 'package:trvlez_mobile/features/auth/presentation/providers/auth_providers.dart'
    show
        registrationControllerProvider,
        registrationNotifierProvider,
        RegistrationNotifier;

typedef RegistrationController = RegistrationNotifier;
