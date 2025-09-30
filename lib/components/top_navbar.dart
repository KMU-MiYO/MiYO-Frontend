import 'package:flutter/material.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget{
  const TopNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          children: [
            Text(
                  'MiYO',
                  style: TextStyle(
                    color: Color(0xff00AA5D),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            Text(
              'Map it Your Own',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xff00AA5D),
                fontWeight: FontWeight.w400,
              )
            )
          ],
        ),
      
      ),
    );
  }

  //
  @override
  Size get preferredSize => Size.fromHeight(52);
}