import 'package:flutter/material.dart';

class BidPage extends StatefulWidget {
  final String stringBid;

  const BidPage({super.key, required this.stringBid});

  @override
  State<BidPage> createState() => _BidPageState();
}

class _BidPageState extends State<BidPage> {
  late int bid;
  final TextEditingController _controller = TextEditingController();

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
        title: const Text(
          'Bids',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Bid:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$$bid',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter your bid',
                border: OutlineInputBorder(),
                labelText: 'Your Bid',
                prefixText: '\$',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBid,
                child: const Text('Bid Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
