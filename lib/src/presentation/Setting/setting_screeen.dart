import 'package:flutter/material.dart';

class SettingScreeen extends StatelessWidget {
  const SettingScreeen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.amber,
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                title: Text('Profile', style: TextStyle(fontSize: 18)),
                trailing: Icon(Icons.arrow_forward_ios, size: 18,),
              ),
               ListTile(
                title: Text('Profile', style: TextStyle(fontSize: 18)),
                trailing: Icon(Icons.arrow_forward_ios, size: 18,),
              ), ListTile(
                title: Text('Profile', style: TextStyle(fontSize: 18)),
                trailing: Icon(Icons.arrow_forward_ios, size: 18,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
