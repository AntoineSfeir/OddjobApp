import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:odd_job_app/chat/chat_service.dart";

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String recieverUser;
  const ChatPage({super.key, required this.recieverEmail, required this.recieverUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

ChatService chat = new ChatService();

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth auth = FirebaseAuth.instance;


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
    String? userEmail = auth.currentUser?.email;
    String user;
    if (userEmail != null) {
      user = userEmail;
    } else {
      user = "null value";
    }
    return StreamBuilder(
      stream: chat.getMessages(user, widget.recieverEmail),
      builder: (context, snapshot) {
        return ListView(
          children: snapshot.data!.docs.map((document) => buildMessageItem(document)).toList(),
        );
      },
    );
  }



  Widget buildMessageItem(DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      var alignment = (data['recieverEmail'] == auth.currentUser!.email) ? Alignment.centerRight : Alignment.centerLeft;

      return Container(
        alignment: alignment,
        child: Text(data['message'])
        );
  }

  Widget buildMessageInput() {
    return Row(
      children: [
        //need to make a text input box
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
