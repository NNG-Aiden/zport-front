import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      bottomNavigationBar: BottomNavigationBar(type: BottomNavigationBarType.fixed,
          onTap: (index) => {},
          currentIndex: 0,
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('홈'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.search),
              title: Text('팀 탐색'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.flag),
              title: Text('대외활동'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('내 정보'),
            ),
          ],
      ),
    );
  }
}
