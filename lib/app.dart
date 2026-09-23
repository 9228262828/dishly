import 'package:flutter/material.dart';
import 'screens.dart';
import 'store.dart';
import 'ui.dart';

class DishlyApp extends StatefulWidget {
  const DishlyApp({super.key});

  @override
  State<DishlyApp> createState() => _DishlyAppState();
}

class _DishlyAppState extends State<DishlyApp> {
  final store = DishlyStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DISHLY',
          theme: dishlyTheme(Brightness.light),
          darkTheme: dishlyTheme(Brightness.dark),
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(store: store),
        );
      },
    );
  }
}
