import 'package:flutter/material.dart';
import 'package:p_project1/dashboard.dart'; // Make sure to import Dashboard
import 'package:p_project1/add_user.dart';  // Make sure to import AddUser

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState(); 
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Dashboard()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.image),
            title: Text('Add User'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AddUser()),
              );
            },
          ),
        ],
      ),
    );
  }
}
