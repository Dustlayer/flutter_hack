import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/screens/match_history_screen.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';
import 'navigation/page_routes.dart';
import 'screens/screens.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        PageRoutes.home: (context, state, data) => HomeScreen(),
        PageRoutes.leaderboard: (context, state, data) => LeaderboardScreen(),
        // '/play': (context, state, data) => PlayScreen(),
        PageRoutes.singleplayer: (context, state, data) =>
            PlaySingleplayerScreen(),
        PageRoutes.multiplayer: (context, state, data) =>
            PlayMultiplayerScreen(),
        PageRoutes.multiplayerGame: (context, state, data) =>
            PlayMultiplayerScreen(
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
      ],
      child: MaterialApp.router(
        title: 'Flutter Puzzle Hack',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        routerDelegate: routerDelegate,
        routeInformationParser: BeamerParser(),
        backButtonDispatcher:
            BeamerBackButtonDispatcher(delegate: routerDelegate),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test text'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(child: MatchHistoryScreen()),
        ],
      ),
    );
  }
}
