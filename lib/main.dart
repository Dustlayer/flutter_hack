import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hack/screens/match_history_screen.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';
import 'navigation/page_routes.dart';
import 'screens/screens.dart';

void main() {
  Cube cube = Cube();

  print("Before");
  cube.debugPrint();

  cube.turnRowRight(0);

  print("After");
  cube.debugPrint();


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
        PageRoutes.singleplayer: (context, state, data) => PlaySingleplayerScreen(),
        PageRoutes.multiplayer: (context, state, data) => PlayMultiplayerScreen(),
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
      ],
      child: MaterialApp.router(
        title: 'Flutter Puzzle Hack',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        routerDelegate: routerDelegate,
        routeInformationParser: BeamerParser(),
        backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate),
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

class Block {
  int value;
  Block(this.value);

  @override
  String toString() => 'Block $value';
}

class Face {
  late Face left, right;
  List<List<Block>> blocks = List.empty(growable: true);
  bool isShifting = false;

  Face(int width, int height, int offset) {
    for (int r = 0; r < height; r++) {
      List<Block> row = List.empty(growable: true);
      for (int c = 0; c < width; c++) {
        row.add(Block(offset + r * width + c));
      }
      blocks.add(row);
    }
  }

  void debugPrint() {
    for (int r = 0; r < blocks.length; r++) {
      print("Row $r: " + blocks[r].join(", "));
    }
  }

  void init(Face left, Face right) {
    this.left = left;
    this.right = right;
  }

  void shiftRight(int rowIndex) {
    isShifting = true;

    List<Block> row = blocks[rowIndex];
    Block shift = left.getRightmost(rowIndex);

    row.insert(0, shift);

    if (!left.isShifting) {
      left.shiftRight(rowIndex);
    }

    row.removeLast();

    isShifting = false;
  }

  void shiftLeft(int rowIndex) {
    isShifting = true;

    List<Block> row = blocks[rowIndex];
    Block shift = right.getLeftmost(rowIndex);

    row.add(shift);

    if (!right.isShifting) {
      right.shiftLeft(rowIndex);
    }

    row.removeAt(0);

    isShifting = false;
  }

  Block getRightmost(int rowIndex) {
    return blocks[rowIndex].last;
  }

  Block getLeftmost(int rowIndex) {
    return blocks[rowIndex].first;
  }
}

class Cube {
  late Face front;

  Cube() {
    Face front = Face(3, 3, 0);
    Face left = Face(3, 3, 9);
    Face right = Face(3, 3, 18);
    Face back = Face(3, 3, 27);

    front.init(left, right);
    left.init(back, front);
    back.init(right, left);
    right.init(front, back);

    this.front = front;
  }

  void turnLeft() {
    front = front.right;
  }

  void turnRight() {
    front = front.left;
  }

  void turnRowRight(int rowIndex) {
    front.shiftRight(rowIndex);
  }

  void turnRowLeft(int rowIndex) {
    front.shiftLeft(rowIndex);
  }

  void debugPrint() {
    // todo this -vv-
    //     xxx
    //     xxx
    //     xxx
    // xxx xxx xxx xxx
    // xxx xxx xxx xxx
    // xxx xxx xxx xxx
    //     xxx
    //     xxx
    //     xxx

    // whack as always
    print("Left:");
    front.left.debugPrint();

    print("Front:");
    front.debugPrint();

    print("Right");
    front.right.debugPrint();

    print("Back");
    front.right.right.debugPrint();
  }

}
