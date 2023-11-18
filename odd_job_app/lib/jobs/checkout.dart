import 'package:flutter/material.dart';
import 'package:odd_job_app/jobs/test.dart';

class CheckOut extends StatefulWidget {
  final String stringBid;

  const CheckOut({Key? key, required this.stringBid}) : super(key: key);

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  late int bid;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    bid = int.parse(widget.stringBid);
  }

  void _saveBid() {
    setState(() {
      bid = int.tryParse(_controller.text) ?? bid;
    });
    // You can perform any action with the saved bid value here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Out'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Current Bid:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Text(
                  '\$$bid',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter your bid',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveBid,
              child: Text('Bid Now'),
            ),
          ],
        ),
      ),
    );
  }
}
