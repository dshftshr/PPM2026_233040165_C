  import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 24, color: Colors.red),
            Icon(Icons.receipt, size: 48, color: Colors.green),
            Icon(Icons.refresh, size: 64, color: Colors.purple)
          ],
        )
      ),
    )
  ));
}