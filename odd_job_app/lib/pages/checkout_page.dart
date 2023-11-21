import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  double communicationRating = 0;
  double workQualityRating = 0;
  double trustScoreRating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job summary
            Text(
              'Job Summary:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Display job summary details here
            // You can replace the placeholder text with actual job details

            // Billing information
            const SizedBox(height: 20),
            Text(
              'Billing Information:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Display billing information form here
            // You can replace the placeholder text with actual billing form

            // Ratings
            const SizedBox(height: 20),
            Text(
              'Leave Ratings:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            // Communication rating
            buildRatingBar(
              'Communication',
              communicationRating,
              (rating) {
                setState(() {
                  communicationRating = rating;
                });
              },
            ),
            // Work quality rating
            buildRatingBar(
              'Work Quality',
              workQualityRating,
              (rating) {
                setState(() {
                  workQualityRating = rating;
                });
              },
            ),
            // Trust score rating
            buildRatingBar(
              'Trust Score',
              trustScoreRating,
              (rating) {
                setState(() {
                  trustScoreRating = rating;
                });
              },
            ),

            // Checkout button
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement checkout functionality
              },
              child: const Text('Proceed to Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRatingBar(String label, double rating, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            // You can replace this with your preferred rating widget
            for (int i = 1; i <= 5; i++)
              IconButton(
                onPressed: () => onChanged(i.toDouble()),
                icon: Icon(
                  i <= rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
