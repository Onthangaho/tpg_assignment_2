/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */

import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {


  final String id;
  final String studentId;
  final String lecturerId;
  final String module;
  final DateTime dateTime;
  final String topic;
  final String notes;
  final String status;

  BookingModel({required this.id, required this.studentId,required this.lecturerId, required this.module,
  required this.dateTime, required this.topic,required this.notes,required this.status});

   Map<String, dynamic> toFirestore() => {
        'id': id,
        'studentId': studentId,
        'lecturerId': lecturerId,
        'module': module,
        'dateTime': dateTime.toIso8601String(),
        'topic': topic,
        'notes': notes,
        'status': status,
      };
    static BookingModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      studentId: data['studentId'],
      lecturerId: data['lecturerId'],
      module: data['module'],
      dateTime: data['dateTime'] is Timestamp 
        ? (data['dateTime'] as Timestamp).toDate() // 🔹 Convert Timestamp to DateTime
        : DateTime.parse(data['dateTime']),
      topic: data['topic'],
      notes: data['notes'],
      status: data['status'],
    );
  }

}