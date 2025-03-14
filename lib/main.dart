import 'package:flutter/material.dart';
import 'package:project_2/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Split Bill App',
        theme: AppTheme.theme,
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
