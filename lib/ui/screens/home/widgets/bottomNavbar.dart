import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardAllTimeCubit.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardDailyCubit.dart';
import 'package:flutterquiz/features/leaderBoard/cubit/leaderBoardMonthlyCubit.dart';
import 'package:flutterquiz/ui/screens/home/home_screen.dart';
import 'package:flutterquiz/ui/screens/home/leaderboard_screen.dart';
import 'package:flutterquiz/ui/screens/quiz/contest_screen.dart';

class buildbottomnavbar extends StatefulWidget {
  final bool isGuest;

  const buildbottomnavbar({Key? key, required this.isGuest}) : super(key: key);

  @override
  _buildbottomnavbarState createState() => _buildbottomnavbarState();


  
  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as bool? ?? false; // Default to false if no argument is passed
    return CupertinoPageRoute(
      builder: (_) => buildbottomnavbar(isGuest: args),
    );
  }
}


class _buildbottomnavbarState extends State<buildbottomnavbar> {

  @override
  void initState() {
    super.initState();
  }
  int _currentIndex = 0;

  
  List<Widget> _buildScreens() {
    return [
      HomeScreen(isGuest: true,),
      
      ContestScreen(),
       ContestScreen(),
  MultiBlocProvider(
      providers: [
        BlocProvider<LeaderBoardMonthlyCubit>(
          create: (_) => LeaderBoardMonthlyCubit(),
        ),
        BlocProvider<LeaderBoardDailyCubit>(
          create: (_) => LeaderBoardDailyCubit(),
        ),
        BlocProvider<LeaderBoardAllTimeCubit>(
          create: (_) => LeaderBoardAllTimeCubit(),
        ),
      ],
      child: const LeaderBoardScreen(),
    ),
    ];
  }

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreens()[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        height: 60.0, // Height of the curved nav bar
        items: <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.quiz, size: 30, color: Colors.white),
          Image.asset("assets/images/trophy.png", height: 30, width: 30,color: Colors.white,),
          Icon(Icons.leaderboard, size: 30, color: Colors.white),
        ],
        color: Colors.blue,
        buttonBackgroundColor: Colors.blueAccent, 
        backgroundColor: Colors.white, 
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
      ),
    );
  }
}