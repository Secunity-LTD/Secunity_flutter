import 'package:cloud_firestore/cloud_firestore.dart';

class TeamService {
  String leaderUid;
  // collection reference
  final CollectionReference teamCollection = FirebaseFirestore.instance.collection('teams');

  TeamService({required this.leaderUid});

  Future createTeam(String name, String city) async {
    return await teamCollection.add({
      'leader uid': leaderUid,
      'team name': name,
      'city': city,
      'members': [],
      'alert': false,
    });
  }

 // // Create new Team method
 //  void _createSquad(String squadName, String squadCity) async {
 //    if (squadName.isNotEmpty && squadCity.isNotEmpty) {
 //      try {
 //        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
 //            .collection('squads')
 //            .where('name', isEqualTo: squadName)
 //            .get();
 //
 //        if (querySnapshot.docs.isNotEmpty) {
 //          _showSnackBar('A squad with the same name already exists.');
 //        } else {
 //          await FirebaseFirestore.instance.collection('squads').add({
 //            'squad_name': squadName,
 //            'city': squadCity,
 //            'leader': FirebaseAuth.instance.currentUser!.uid,
 //            'members': [],
 //            'alert': false,
 //          });
 //          squadNameController.clear();
 //          setState(() {
 //            squadCreated = true;
 //          });
 //          _showSnackBar('Squad created successfully!');
 //        }
 //      } catch (e) {
 //        print('Error creating squad: $e');
 //      }
 //    } else {
 //      _showSnackBar('Squad name and city cannot be empty.');
 //    }
 //  }

}