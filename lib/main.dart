import 'package:apsaratalent_mobile/core/configs/config_service.dart';
import 'package:apsaratalent_mobile/core/enums/environment_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfigService.initialize(EEnvironmentType.development);

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
