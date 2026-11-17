import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'home_widget/home_widget_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('fr_FR');

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    await HomeWidget.setAppGroupId(AeHomeWidgetConfig.iosAppGroupId);
  }

  runApp(const ProviderScope(child: AutoEntrepreneurApp()));
}
