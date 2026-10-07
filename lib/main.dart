import 'package:apsaratalent_mobile/core/configs/config_service.dart';
import 'package:apsaratalent_mobile/core/configs/environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/push/push_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfigService.initialize(AppEnvironmentConfig.fromBuild());
  await PushBootstrap.initialize();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
