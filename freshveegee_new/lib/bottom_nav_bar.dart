import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'camera.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const FruitScanner(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Disable the physical back button by returning false in onWillPop
  Future<bool> _onWillPop() async {
    return false; // Return false to prevent the back button from closing the screen
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Disable the back button here
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Stack(
          children: [
            CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _NavBarPainter(),
            ),
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavBarItem(Icons.home, 0),
                  _buildNavBarItem(Icons.camera_alt, 1, isCenter: true),
                  _buildNavBarItem(Icons.person, 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, int index, {bool isCenter = false}) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCenter) const SizedBox(height: 10), // For center alignment
          Container(
            height: isSelected ? 50 : 40,
            width: isSelected ? 50 : 40,
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.white,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: isSelected ? 30 : 24,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the background
class _NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.25,
        0,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
