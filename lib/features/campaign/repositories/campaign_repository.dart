import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/models/character.dart';

class CampaignRepository {
  final FirebaseFirestore firestore;

  CampaignRepository(this.firestore);

  Stream<List<Character>> listenToPlayers(String campaignId) {
    return firestore
        .collection('campaigns')
        .doc(campaignId)
        .collection('players')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Character.fromJson(doc.data())).toList());
  }

  Future<List<Character>> fetchPlayers(String campaignId) async {
    final snap = await firestore
        .collection('campaigns')
        .doc(campaignId)
        .collection('players')
        .get();

    return snap.docs.map((doc) => Character.fromJson(doc.data())).toList();
  }
}
