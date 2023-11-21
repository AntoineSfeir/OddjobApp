import 'package:odd_job_app/jobs/job.dart';
import 'package:odd_job_app/jobs/user.dart';

class bid {
  late user bidder;
  late String amount;
  late Job jobThatWasBidOn;
  late String bidID;
  late String jobFileBidID;
  bid({
    required this.bidder,
    required this.amount,
    required this.jobThatWasBidOn,
  });
}
