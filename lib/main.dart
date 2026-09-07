import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/app_state.dart';
import 'presentation/screens/remote_screen.dart';
import 'presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.init();
  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const IotRemoteApp(),
    ),
  );
}

class IotRemoteApp extends StatelessWidget {
  const IotRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Điều khiển máy lạnh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const RemoteScreen(),
    );
  }
}
