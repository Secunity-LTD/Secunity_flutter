// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class ScheduelService {
//   String leaderUid;
//   ScheduelService(String leaderUid){
//     this.leaderUid = leaderUid;
//     _initializeTaskControllers();
//   }
//
//   String _getDayName(int index) {
//     List<String> days = [
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//       'Friday',
//       'Saturday',
//       'Sunday'
//     ];
//     return days[index];
//   }
//
//   String _getTimeName(int index) {
//     List<String> times = ['Morning', 'Evening', 'Night'];
//     return times[index];
//   }
//
//
//
//   void _initializeTaskControllers() async {
//     try {
//       // Fetching squad ID where current user is the leader
//       QuerySnapshot squadSnapshot = await FirebaseFirestore.instance
//           .collection('squads')
//           .where('leader', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//           .get();
//
//       // Initialize the taskControllers list if it's null or empty
//       if (taskControllers == null || taskControllers.isEmpty) {
//         taskControllers = List.generate(
//             7, (_) => List.generate(3, (_) => TextEditingController()));
//       }
//
//       if (squadSnapshot.docs.isNotEmpty) {
//         // Getting the ID of the first squad (assuming user can lead only one squad)
//         String squadId = squadSnapshot.docs.first.id;
//
//         for (int i = 0; i < 7; i++) {
//           for (int j = 0; j < 3; j++) {
//             String day = _getDayName(i);
//             String time = _getTimeName(j);
//             DocumentSnapshot taskSnapshot = await FirebaseFirestore.instance
//                 .collection('squad_tasks')
//                 .doc(
//                 '$day-$time-$squadId') // Using squad ID in task document ID
//                 .get();
//
//             if (taskSnapshot.exists) {
//               Map<String, dynamic>? data =
//               taskSnapshot.data() as Map<String, dynamic>?;
//
//               if (data != null && data.containsKey('task')) {
//                 taskControllers[i][j] =
//                     TextEditingController(text: data['task']);
//               }
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print('Error initializing task controllers: $e');
//     }
//   }
// }