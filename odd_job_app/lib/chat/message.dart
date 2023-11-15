import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderEmail;
  final String receiverEmail;
  final String message;
  //final Timestamp timestamp;
  final FieldValue timestamp;

  Message({
    required this.senderEmail,
    required this.receiverEmail,
    required this.message,
    required this.timestamp
    });


  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'recieverUser': receiverEmail,
      'message': message,
      'timestamp': timestamp
    };
  }

}