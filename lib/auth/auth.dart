// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_form/models/booking_model.dart';
import 'package:login_form/models/user_model.dart';
import 'package:login_form/views/admin_dashboard.dart';
import 'package:login_form/views/login_Screen.dart';
import 'package:login_form/views/student_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends ChangeNotifier{


  final _auth =FirebaseAuth.instance;

  final _firestore= FirebaseFirestore.instance;

   // Getter for authenticated user
  User? get currentUser => _auth.currentUser;



   Future<void> register(BuildContext context, String name, String email, String password, String? studentNumber, String? contactNumber, bool isAdmin) async {
  try {
    if (isAdmin && !email.endsWith('@cut.ac.za')) throw 'Admin email must end with @cut.ac.za';
    if (!isAdmin && !email.endsWith('@stud.cut.ac.za')) throw 'Student email must end with @stud.cut.ac.za';

    final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    String role = isAdmin ? "admin" : "student";

    UserModel newUser = UserModel(
      id: userCredential.user!.uid,
      name: name,
      email: email,
      role: role,
      studentNumber: isAdmin ? null : studentNumber,
      contactNumber: isAdmin ? null : contactNumber,
      createdAt: DateTime.now(),
    );

    await _firestore.collection(isAdmin ? 'admins' : 'students').doc(userCredential.user!.uid).set(newUser.toFirestore());

    notifyListeners();
    
    // Redirect user to login screen after successful registration

    
    
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ));
  } on FirebaseAuthException catch (e) {
    throw _authError(e.code);
  }
}

   // Logout method
  Future<void> logoutUser() async {
    await _auth.signOut();
    notifyListeners();
  }


   // Fetch user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('students').doc(uid).get();
    bool isStudent=doc.exists;

    if(!isStudent){

      doc = await _firestore.collection('admins').doc(uid).get();
    if (!doc.exists) return null; // No user found

    }
   return UserModel.fromFirestore(doc);
  }


  Future<List<Map<String, dynamic>>> getAdminLecturers() async {
  QuerySnapshot snapshot = await _firestore.collection('admins').get();
  return snapshot.docs.map((doc) => {
    'id': doc.id,
    'name': doc['name'],
    'email': doc['email'],
  }).toList();
}

Future<void> _storeUserSession(String userId, String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userUID', userId);
  await prefs.setString('userEmail', email);
}

  // Login a user
Future<User?> login(BuildContext context, String email, String password, bool rememberMe) async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

    if (userCredential.user == null) {
      throw 'Login failed: No user found';
    }

    String userId = userCredential.user!.uid;

    // 🔹 Store user session if "Remember Me" is enabled
    if (rememberMe) {
      await _storeUserSession(userId, email);
    }

    // 🔹 Check Firestore role
    DocumentSnapshot userDoc = await _firestore.collection('students').doc(userId).get();
    bool isStudent = userDoc.exists;

    if (!isStudent) {
      userDoc = await _firestore.collection('admins').doc(userId).get();
      if (!userDoc.exists) {
        throw 'User not found';
      }
    }

    final userData = userDoc.data() as Map<String, dynamic>?; 
    if (userData == null || !userData.containsKey('role')) {
      throw 'Invalid user data';
    }

    String role = userData['role'];

    // 🔹 Navigate based on role
    if (role == 'student') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentHomeScreen(email: email)));
    } else if (role == 'admin') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
    } else {
      throw 'Unknown user role';
    }

    return userCredential.user;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Login Failed: ${e.toString()}")));
    return null;
  }
}

//auto login
Future<void> autoLogin(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final savedEmail = prefs.getString('userEmail');
  final savedUserId = prefs.getString('userUID'); // 🔹 Retrieve stored user ID

  if (savedEmail != null && savedUserId != null) {
    try {
      // 🔹 Check Firestore for user role
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('students').doc(savedUserId).get();
      bool isStudent = userDoc.exists;

      if (!isStudent) {
        userDoc = await FirebaseFirestore.instance.collection('admins').doc(savedUserId).get();
        if (!userDoc.exists) throw 'User role not found';
      }

      final userData = userDoc.data() as Map<String, dynamic>?; 
      if (userData == null || !userData.containsKey('role')) {
        throw 'Invalid user data';
      }

      String role = userData['role'];

      // 🔹 Navigate based on role
      if (role == 'student') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StudentHomeScreen(email: savedEmail)));
      } else if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
      } else {
        throw 'Unknown user role';
      }
    } catch (e) {
      print("❌ Auto-login failed: $e");
    }
  }
}
  // Authentication error handling
  String _authError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email format';
      case 'weak-password':
        return 'Password must be at least 8 characters';
      case 'email-already-in-use':
        return 'Email is already registered';
      default:
        return 'Authentication failed';
    }
  }

  // Module Collection Reference
  Future<String?> bookConsultation(BookingModel booking)async{
   if(booking.dateTime.isBefore(DateTime.now())) return "Consultation date must be in the future!";
   

   try{

    await _firestore.collection('bookings').doc(booking.id).set(booking.toFirestore());
    notifyListeners();
    return null;

   }catch(e){

    return e.toString();
   }

  }

  //fetch student's bookings
Stream<List<BookingModel>> getBookings(String studentId) {
  return _firestore
      .collection('bookings')
      .where('studentId', isEqualTo: studentId) // 🔹 Ensure only student’s bookings are fetched
      .orderBy('dateTime', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() ;
            return BookingModel(
              id: doc.id,
              studentId: data['studentId'],
              lecturerId: data['lecturerId'],
              module: data['module'],
              dateTime: data['dateTime'] is Timestamp
                  ? (data['dateTime'] as Timestamp).toDate() // Convert Timestamp
                  : DateTime.now(),
              topic: data['topic'],
              notes: data['notes'],
              status: data['status'],
            );
          }).toList());
}
//update booking
  Future<void> updateBooking(
  String bookingId, String module, DateTime dateTime, String topic, String notes, String studentId
) async {
  try {
    // Retrieve booking first to verify ownership
    DocumentSnapshot bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
    if (!bookingDoc.exists) throw 'Booking not found';
    
    Map<String, dynamic> bookingData = bookingDoc.data() as Map<String, dynamic>;
    if (bookingData['studentId'] != studentId) throw 'Unauthorized: You can only edit your own bookings';

    // If student owns the booking, update it
    await _firestore.collection('bookings').doc(bookingId).update({
      'module': module,
      'dateTime': Timestamp.fromDate(dateTime), // Convert DateTime to Timestamp
      'topic': topic,
      'notes': notes,
      'status': 'updated',
    });

    notifyListeners(); // Refresh UI if needed
  } catch (e) {
    throw 'Booking Update Failed: ${e.toString()}';
  }
}
Future<void> deleteBooking(String bookingId) async {
  try {
    // Retrieve booking first to verify ownership
    DocumentSnapshot bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
    if (!bookingDoc.exists) throw 'Booking not found';

    Map<String, dynamic> bookingData = bookingDoc.data() as Map<String, dynamic>;
    String studentId = bookingData['studentId'];

    // Ensure only the booking owner can delete it
    if (studentId != _auth.currentUser!.uid) throw 'Unauthorized: You can only delete your own bookings';

    await _firestore.collection('bookings').doc(bookingId).delete();

    notifyListeners();
    print("✅ Booking Deleted: $bookingId"); // Debug print for confirmation
  } catch (e) {
    print("❌ Error Deleting Booking: $e"); // Debug print for troubleshooting
    throw 'Booking Deletion Failed: ${e.toString()}';
  }
}
  //update user Profile
  Future<void> updateUserProfile(String userId, String name, String studentNumber, String contactNumber) async {
  try {
    await _firestore.collection('students').doc(userId).update({
      'name': name,
      'studentNumber': studentNumber,
      'contactNumber': contactNumber,
    });

    notifyListeners(); // Ensures UI updates dynamically after profile change
  } catch (e) {
    throw "❌ Profile Update Failed: ${e.toString()}";
  }
}
}


