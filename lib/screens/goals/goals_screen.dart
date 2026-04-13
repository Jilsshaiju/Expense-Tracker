import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';

class GoalsScreen extends StatelessWidget {
  final bool isTab;
  const GoalsScreen({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(isTab: isTab);
  }
}
