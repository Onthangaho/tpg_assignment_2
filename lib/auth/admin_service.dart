import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Get All Student Bookings from Firestore**
  Stream<List<BookingModel>> getAllBookings() {
    return _firestore.collection('bookings').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList());
  }

  /// **Delete Booking**
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      print("❌ Error deleting booking: $e");
      rethrow;
    }
  }
}