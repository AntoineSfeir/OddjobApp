import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:odd_job_app/chat/chat_service.dart";
import "package:odd_job_app/chat/message_bubble.dart";

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String recieverUser;
  const ChatPage({super.key, required this.recieverEmail, required this.recieverUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}


class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  ChatService chat = new ChatService();


  void sendMessage() async {
    if(_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.recieverEmail, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(title: Text(widget.recieverUser)),
    body: Column( 
      children: [
        Expanded(
          child: buildMessageList(),
        ),



        buildMessageInput(),
      ],
    )
    );
  }


  Widget buildMessageList() {
  return StreamBuilder(
    stream: chat.getMessages(auth.currentUser?.email ?? '', widget.recieverEmail),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error ${snapshot.error}');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text("Loading");
      }
      return ListView(
        children: snapshot.data!.docs.map((document) => buildMessageItem(document)).toList(),
      );
    },
  );
}




  Widget buildMessageItem(DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      var alignment = (data['recieverUser'] != auth.currentUser!.email) ? Alignment.centerRight : Alignment.centerLeft;

      return Container(
        alignment: alignment,
        child: Padding (
          padding: EdgeInsets.all(8.0),
        child: ChatBubble(message: data['message'], isSender: (data['recieverUser'] != auth.currentUser!.email) )
        ),
      );
  }

  Widget buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Enter Message',
                        ),
                      )
        ),

        IconButton(onPressed: sendMessage, icon: Icon(Icons.arrow_upward))

      ],
    );
  }
}
