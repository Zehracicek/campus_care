import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'my_app.dart';

/// Artılar +++++
/// uygulamanın daha rahat test edilebilmesini ve modüler olmasını sağlıyor.
/// Ekstra özellikler ekleyebilirsin ve uygulamayı daha esnek hale getirebilirsin.
/// Eksiler -----
/// başlangıçta biraz daha karmaşık olabilir ve öğrenme eğrisi olabilir.
/// çok fazla dosya oluşturuyorsun, bu da yönetimi zorlaştırabilir.
/// Küçük projelerde zaman kaybına sebep olabilir.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('tr');

  runApp(ProviderScope(child: const MyApp()));
}
