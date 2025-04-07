import 'package:flutter/material.dart';
import 'package:ridesafe/screens/home_page.dart';
import 'package:ridesafe/screens/profile_page.dart';
import 'package:ridesafe/screens/location_page.dart';
import 'package:ridesafe/screens/notification_page.dart';

class BaseLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const BaseLayout({
    Key? key,
    required this.child,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LocationPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: widget.child),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
                size: 28,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey[600],
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.location_on_rounded,
                size: 28,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey[600],
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications_rounded,
                size: 28,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey[600],
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_rounded,
                size: 28,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey[600],
              ),
              label: '',
            ),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}