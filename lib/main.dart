import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'configs/environment.dart';
import 'main/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: AppEnvironmentConfig.envFileName);

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
