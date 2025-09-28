import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget{
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
              'MiYO',
            ),
      
      ),
    );
  }

  //
  @override
  Size get preferredSize => Size.fromHeight(52);
}