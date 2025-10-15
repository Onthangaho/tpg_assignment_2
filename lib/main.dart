
/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:login_form/app/splash_screen/splash_screen.dart';
import 'package:login_form/auth/admin_service.dart';
import 'package:login_form/auth/auth.dart';

import 'package:login_form/reg.dart';
import 'package:login_form/view_models/admin_view_model.dart';
import 'package:login_form/view_models/profile_view_model.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); //
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
  await  Firebase.initializeApp(options: const FirebaseOptions(apiKey: "AIzaSyCfcuc1839cIfICXJ3vS0LoAZDVWaScqwE",
  authDomain: "set-firebase-c2165.firebaseapp.com",
  projectId: "set-firebase-c2165",
  storageBucket: "set-firebase-c2165.firebasestorage.app",
  messagingSenderId: "304727489386",
  appId: "1:304727489386:web:dd7450a0859f5698ee8313"));
  }else{
  await  Firebase.initializeApp();
  }
  

  
   final Auth authService = Auth();

   final AdminService adminService=AdminService();
  runApp
  
  (
    MultiProvider(

     providers: [
       ChangeNotifierProvider(
      create: (context) => Auth(),),
      ChangeNotifierProvider(create:(context) => ProfileViewModel(authService),),

      ChangeNotifierProvider(create:(context) => AdminViewModel(adminService),)

     ], 
     child:  const MyApp(),
    )
   
      
    
    
   );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Consultation booking app',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.deepPurple, // Set background color for the bottom navigation
          selectedItemColor: Colors.white, // Set selected icon color
          unselectedItemColor: Colors.white54, // Set unselected icon color
        ),
      ),
      
      home: const SplashScreen(
        
        child: RegForm() ,
      ),
    );
  }
}