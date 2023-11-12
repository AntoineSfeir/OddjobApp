import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:odd_job_app/chat/message.dart";

class ChatService extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //send
  Future<void> sendMessage(String recieverEmail, String message) async {
    final String currentEmail = auth.currentUser!.email.toString();
    final Timestamp time = Timestamp.now();

    Message newMessage = Message(
      senderEmail: currentEmail,
      receiverEmail: recieverEmail,
      message: message,
      timestamp: time,
    );

  List<String> users = [currentEmail, recieverEmail];
  users.sort();
  String chatRoomName = users.join("_");

  await firestore.collection("chatrooms").doc(chatRoomName).collection('messages').add(newMessage.toMap());
  }


  //get
  Stream<QuerySnapshot> getMessages(String userEmail, String otherEmail) {
      List<String> users = [userEmail, otherEmail];
  users.sort();
  String chatRoomName = users.join("_");

  return firestore
    .collection('chatrooms')
    .doc(chatRoomName)
    .collection('messages')
    .orderBy('timestamp', descending: false)
    .snapshots();
  }
}
