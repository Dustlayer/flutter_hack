// ignore_for_file: avoid_print

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';
import 'navigation/page_routes.dart';
import 'screens/screens.dart';

///
/// # Todos (due 28.02.22!)
/// - main game logic
///   - initialize -> 'shuffle'
///   - win condition
///
///  - victory screen
///    - show score
///    - route back to home
///    - restart game
///
/// -- Code Cleanup --
/// -> Ui, Controller, Data
///
/// - publishing
///   - Text description
///   - Video <= 3min
///   - Hosting
///   - Code comments?
///
/// # Extra:
/// - improve spinning (visual)
/// - custom renderer (opengl)
/// - gesture input (touch/click and drag + modifiers to switch 'modes')
/// - multiplayer (versus)
///
/// # Ideas
/// - coop multiplayer

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        PageRoutes.home: (context, state, data) => HomeScreen(),
        PageRoutes.leaderboard: (context, state, data) => const LeaderboardScreen(),
        // '/play': (context, state, data) => PlayScreen(),
        PageRoutes.singleplayer: (context, state, data) => const PlaySingleplayerScreen(),
        // TestStack(),
        // CubeTestWidget(Cube()),
        PageRoutes.multiplayer: (context, state, data) => const PlayMultiplayerScreen(),
        PageRoutes.multiplayerGame: (context, state, data) => PlayMultiplayerScreen(
              gameId: state.pathParameters['gameId'],
            ),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MatchHistoryManager()),
        ChangeNotifierProvider(create: (context) => KeyboardMetaKeysManager()),
      ],
      child: MaterialApp.router(
        title: 'Flutter Puzzle Hack',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryTextTheme: const TextTheme(labelMedium: TextStyle(color: Colors.greenAccent)),
        ),
        routerDelegate: routerDelegate,
        routeInformationParser: BeamerParser(),
        backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
      ),
    );
  }
}
