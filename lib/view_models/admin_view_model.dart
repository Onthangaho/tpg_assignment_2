/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */
import 'package:flutter/material.dart';
import 'package:login_form/auth/admin_service.dart';

import '../models/booking_model.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminService _adminService;
  List<BookingModel> _allBookings = [];

  AdminViewModel(this._adminService);

  Stream<List<BookingModel>> get allBookings =>_adminService.getAllBookings();



  Future<void> deleteBooking(String bookingId) async {
    try {
      await _adminService.deleteBooking(bookingId);
      _allBookings.removeWhere((booking) => booking.id == bookingId);
      notifyListeners(); // 🔹 Refresh UI after deletion
    } catch (e) {
      print("❌ Error deleting booking: $e");
    }
  }

  void filterBookingsByDateRange(DateTime startDate, DateTime endDate) {
    _allBookings = _allBookings.where((booking) =>
        booking.dateTime.isAfter(startDate) && booking.dateTime.isBefore(endDate)).toList();
    notifyListeners(); // 🔹 Updates filtered results
  }

  void searchBookingsByStudentId(String studentId) {
    _allBookings = _allBookings.where((booking) => booking.studentId.contains(studentId)).toList();
    notifyListeners(); // 🔹 Updates search results
  }
}