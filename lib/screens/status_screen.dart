import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Status extends StatefulWidget {
  const Status({Key? key}) : super(key: key);

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    fetchReportStatus();
  }

  Future<void> fetchReportStatus() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;

        Stream<DocumentSnapshot> reportStream = FirebaseFirestore.instance
            .collection('report')
            .doc(uid)
            .snapshots();

        reportStream.listen((reportSnapshot) {
          if (reportSnapshot.exists) {
            Map<String, dynamic>? data =
                reportSnapshot.data() as Map<String, dynamic>?;

            if (data != null) {
              String? status = data['status'] as String?;

              setState(() {
                // Update the current step based on the status
                if (status == 'Accepted') {
                  currentStep = 2; // Mark third step as complete
                } else if (status == null) {
                  currentStep = 0; // Reset to the first step
                } else {
                  currentStep = 1; // Mark second step as complete
                }
              });
            }
          }
        });
      }
    } catch (error) {
      // Handle any error that occurs during fetching the report status
      print('Error fetching report status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Status",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('report')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching report status'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          Map<String, dynamic>? data =
              snapshot.data?.data() as Map<String, dynamic>?;

          if (data == null) {
            return Center(
              child: Text('No report found.'),
            );
          }

          String? status = data['status'] as String?;

          return Stepper(
            currentStep: currentStep,
            onStepContinue: () {
              if (currentStep < 2) {
                setState(() {
                  currentStep++;
                });
              }
            },
            steps: [
              Step(
                title: Text('Step 1'),
                content: Text('This is the first Step'),
                isActive: currentStep >= 0,
                state:
                    currentStep >= 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: Text('Step 2'),
                content: Text('This is the second Step'),
                isActive: currentStep >= 1,
                state:
                    currentStep >= 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: Text('Step 3'),
                content: Text('This is the third Step'),
                isActive: currentStep >= 2,
                state:
                    currentStep >= 2 ? StepState.complete : StepState.indexed,
              ),
            ],
          );
        },
      ),
    );
  }
}
