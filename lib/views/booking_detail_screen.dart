/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */
import 'package:flutter/material.dart';
import 'package:login_form/models/booking_model.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

    appBar: AppBar(
      title: const Text('Booking Details'),
    ),

    body: Container(
      width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

      child: Center(


        child: Card(
          elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.all(50),
          
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                    
              children: [
                    
                 Text("📌 Topic: ${booking.topic}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    
                   _buildDetailRow(Icons.person, 'Lecturer', booking.lecturerId),
                  _buildDetailRow(Icons.calendar_today, 'Date & Time', _formatDateTime(booking.dateTime)),
                  _buildDetailRow(Icons.note, 'Notes', booking.notes),


                    
                 const SizedBox(height: 20,),
                    
                 Center(
                   child: ElevatedButton(
                    
                    onPressed: () => Navigator.pop(context),
                     style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white
                      ),

                      
                    child: const Text('Back'),
                   ),
                 )
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 5),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );

  }
  // Format Date & Time for better readability
  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute}";
  }


}