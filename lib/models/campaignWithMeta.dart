import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/campaign.dart';

class CampaignWithMeta {
  final Campaign campaign;
  final Stream<String> hostNameStream;
  final Stream<int> playerCountStream;

  CampaignWithMeta({
    required this.campaign,
    required this.hostNameStream,
    required this.playerCountStream,
  });

  factory CampaignWithMeta.fromCampaign(Campaign campaign) {
    final hostNameStream = FirebaseFirestore.instance
        .collection('users')
        .doc(campaign.hostId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      return (data != null && data.containsKey('username'))
          ? data['username'] as String
          : campaign.hostId;
    });

    final playerCountStream = FirebaseFirestore.instance
        .collection('campaigns')
        .doc(campaign.id)
        .collection('players')
        .snapshots()
        .map((qs) => qs.size);

    return CampaignWithMeta(
      campaign: campaign,
      hostNameStream: hostNameStream,
      playerCountStream: playerCountStream,
    );
  }
}
