import 'package:flutter/material.dart';
import 'package:odd_job_app/pages/creditcard_page.dart';

class PaymentOptionsPage extends StatefulWidget {
  const PaymentOptionsPage({Key? key}) : super(key: key);

  @override
  State<PaymentOptionsPage> createState() => _PaymentOptionsPageState();
}

class _PaymentOptionsPageState extends State<PaymentOptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment Options",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            PaymentOptionCard(
              title: "Credit Card",
              icon: Icons.credit_card,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreditCardPage()),
                );
              },
            ),
            SizedBox(height: 20),
            PaymentOptionCard(
              title: "PayPal",
              icon: Icons.payment,
              onTap: () {
                // Handle PayPal selection
              },
            ),
            SizedBox(height: 20),
            PaymentOptionCard(
              title: "Google Pay",
              icon: Icons.attach_money,
              onTap: () {
                // Handle Google Pay selection
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const PaymentOptionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.blue,
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
