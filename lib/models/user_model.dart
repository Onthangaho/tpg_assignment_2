
/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
   final String id;
  final String name;

  final String email;
  final String role; // "student" or "admin"
  final String? studentNumber; // Only for students
  final String? contactNumber; // Only for students
  final String? profilePicUrl; // Optional profile picture
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.studentNumber,
    this.contactNumber,
    this.profilePicUrl,
    required this.createdAt,
  });
    // Convert object into Firestore format
  Map<String, dynamic> toFirestore() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'studentNumber': studentNumber,
        'contactNumber': contactNumber,
        'profilePicUrl': profilePicUrl,
        'createdAt': createdAt.toIso8601String(),
      };


  // Convert Firestore document to object
  static UserModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      role: data['role'],
      studentNumber: data['studentNumber'],
      contactNumber: data['contactNumber'],
      profilePicUrl: data['profilePicUrl'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }


  

}  