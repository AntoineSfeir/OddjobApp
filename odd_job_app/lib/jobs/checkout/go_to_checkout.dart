import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:odd_job_app/jobs/bid.dart';
import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkout_screen_ui/checkout_page.dart';
import 'package:odd_job_app/pages/home_page2.dart';

class GoToCheckout extends StatefulWidget {
  late final Job jobToCheckout;
  GoToCheckout({required this.jobToCheckout});

  State<GoToCheckout> createState() => _GoToCheckoutState();
}

class _GoToCheckoutState extends State<GoToCheckout> {
  late final Job jobToCheckout;
  late final String userToPay;

  Future<void> getUserToPay() async {
    await FirebaseFirestore.instance.collection('users').get().then(
          (snapshot) => snapshot.docs.forEach((document) {
            if (document.reference.id == jobToCheckout.workerID) {
              setState(() {
                userToPay = document['username'];
              });
            }
          }),
        );
  }

  @override
  void initState() {
    super.initState();
    jobToCheckout = widget.jobToCheckout;
    getUserToPay();
  }

  /// REQUIRED: (If you are using native pay option)
  ///
  /// A function to handle the native pay button being clicked. This is where
  /// you would interact with your native pay api
  Future<void> _nativePayClicked(BuildContext context) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Checkout')));
  }

  /// REQUIRED: (If you are using cash pay option)
  ///
  /// A function to handle the cash pay button being clicked. This is where
  /// you would integrate whatever logic is needed for recording a cash transaction
  Future<void> _cashPayClicked(BuildContext context) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Cash Pay requires setup')));
  }

  @override
  Widget build(BuildContext context) {
    final demoOnlyStuff = DemoOnlyStuff();

    /// RECOMMENDED: A global Key to access the credit card pay button options
    ///
    /// If you want to interact with the payment button icon, you will need to
    /// create a global key to pass to the checkout page. Without this key
    /// the the button will always display 'Pay'. You may view several ways to
    /// interact with the button elsewhere within this example.
    final GlobalKey<CardPayButtonState> _payBtnKey =
        GlobalKey<CardPayButtonState>();

    /// REQUIRED: A function to handle submission of credit card form
    ///
    /// A function is needed to handle your credit card api calls.
    ///
    /// NOTE: This function in our demo example is under the widget's 'build'
    /// method only because it needs access to an instance variable. There is
    /// no requirement to have this function built here in live code.
    Future<void> _creditPayClicked(CardFormResults results) async {
      // you can update the pay button to show something is happening

      //_payBtnKey.currentState?.updateStatus(CardPayButtonStatus.processing);

      // This is where you would implement you Third party credit card
      // processing api
      // demoOnlyStuff.callTransactionApi(_payBtnKey);

      // ignore: avoid_print

      //gets IDS for contractor active

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>  JobPostedSuccessfullyPage(myJob: jobToCheckout,),
      ));

      print("results");
      // WARNING: you should NOT print the above out using live code
    }

    /// REQUIRED: A list of what the user is buying
    ///
    /// A list of item will be needed to pass into the checkout page. This is a
    /// simple demo array of [PriceItem]s used to make the demo work. The total
    /// price is automatically added later.
    final List<PriceItem> _priceItems = [
      PriceItem(
          name: jobToCheckout.title,
          quantity: 1,
          totalPriceCents: int.parse(jobToCheckout.startingBid) * 100),
      PriceItem(
          name: 'Tax',
          quantity: 1,
          totalPriceCents: int.parse(jobToCheckout.startingBid)),
      PriceItem(
          name: 'Fee',
          quantity: 1,
          totalPriceCents: int.parse(jobToCheckout.startingBid))
    ];

    /// REQUIRED: A name representing the receiver of the funds from user
    ///
    /// Demo vendor name provided here. User's need to know who is receiving
    /// their money
    const String _payToName = 'OddJob';

    /// REQUIRED: (if you are using the native pay options)
    ///
    /// Determine whether this platform is iOS. This affects which native pay
    /// option appears. This is the most basic form of logic needed. You adjust
    /// this logic based on your app's needs and the platforms you are
    /// developing for.
    final _isApple = kIsWeb ? false : Platform.isIOS;

    final _isAndroid = kIsWeb ? false : Platform.isAndroid;

    /// RECOMMENDED: widget to display at footer of page
    ///
    /// Apple and Google stores typically require a link to privacy and terms when
    /// your app is collecting and/or transmitting sensitive data. This link is
    /// expected on the same page as the form that the user is filling out. You
    /// can make this any type of widget you want, but we have created a prebuilt
    /// [CheckoutPageFooter] widget that just needs the corresponding links
    const _footer = CheckoutPageFooter(
      // These are example url links only. Use your own links in live code
      privacyLink: 'https://stripe.com/privacy',
      termsLink: 'https://stripe.com/payment-terms/legal',
      note: 'Powered By Not_Stripe',
      noteLink: 'https://stripe.com/',
    );

    /// OPTIONAL: A function for the back button
    ///
    /// This to be used as needed. If you have another back button built into your
    /// app, you can leave this function null. If you need a back button function,
    /// simply add the needed logic here. The minimum required in a simple
    /// Navigator.of(context).pop() request
    Function? _onBack = Navigator.of(context).canPop()
        ? () => Navigator.of(context).pop()
        : null;

    // Put it all together
    return Scaffold(
      appBar: null,
      body: CheckoutPage(
        priceItems: _priceItems,
        payToName: _payToName,
        displayNativePay: !kIsWeb,
        onNativePay: () => _nativePayClicked(context),
        displayCashPay: true,
        onCashPay: () => _cashPayClicked(context),
        isApple: _isApple,
        onCardPay: (results) => _creditPayClicked(results),
        onBack: _onBack,
        payBtnKey: _payBtnKey,
        displayTestData: true,
        footer: _footer,
      ),
    );
  }
}

/// This class is meant to help separate logic that is only used within this demo
/// and not expected to resemble logic needed in live code. That said there may
/// exist some logic that is helpful to use in live code, such as calls to the
/// [CardPayButtonState] key to update its displayed color and icon.
class DemoOnlyStuff {
  // DEMO ONLY:
  // this variable is only used for this demo.
  bool shouldSucceed = true;

  // DEMO ONLY:
  // In this demo, this function is used to delay the resetting of the pay
  // button state in order to allow the user to resubmit the form.
  // If you API calls a failing a transaction, you may need a similar function
  // to update the button from CardPayButtonStatus.fail to
  // CardPayButtonStatus.success. The user will not be able to submit another
  // payment until the button is reset.
  Future<void> provideSomeTimeBeforeReset(
      GlobalKey<CardPayButtonState> _payBtnKey) async {
    await Future.delayed(const Duration(seconds: 2), () {
      _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.ready);
      return;
    });
  }

  Future<void> callTransactionApi(
      GlobalKey<CardPayButtonState> _payBtnKey) async {
    await Future.delayed(const Duration(seconds: 2), () {
      if (shouldSucceed) {
        _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.success);
        shouldSucceed = false;
      } else {
        _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.fail);
        shouldSucceed = true;
      }
      provideSomeTimeBeforeReset(_payBtnKey);
      return;
    });
  }
}

class JobPostedSuccessfullyPage extends StatelessWidget {
  final Job myJob;
  const JobPostedSuccessfullyPage({super.key, required this.myJob});

  Future deleteActive(Job jobToCheckout) async {
    String contractorActiveID = '';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(jobToCheckout.contractorID)
        .collection('ActiveJobs')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              if (element['contractorID'] == jobToCheckout.contractorID &&
                  element['workerID'] == jobToCheckout.workerID) {
                contractorActiveID = element.id;
              }
            }));
    //gets IDs for worker active
    String workerActiveID = '';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(jobToCheckout.workerID)
        .collection('ActiveJobs')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              if (element['contractorID'] == jobToCheckout.contractorID &&
                  element['workerID'] == jobToCheckout.workerID) {
                workerActiveID = element.id;
              }
            }));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(jobToCheckout.contractorID)
        .collection('ActiveJobs')
        .doc(contractorActiveID)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(jobToCheckout.workerID)
        .collection('ActiveJobs')
        .doc(workerActiveID)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: deleteActive(myJob),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Check Mark
                  AnimatedCheckmark(),

                  // Success Message
                  SizedBox(height: 16),
                  Text(
                    'Payment Accepted',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
        ),
      ),
    );
  }
}

class AnimatedCheckmark extends StatefulWidget {
  const AnimatedCheckmark({Key? key}) : super(key: key);

  @override
  _AnimatedCheckmarkState createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    ));

    _controller.forward();

    // Redirect to another page after 4 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage2()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
