import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CampaignScreen extends StatefulWidget {
  final String campaignId;

  const CampaignScreen({super.key, required this.campaignId});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var campaignName = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _getCampaignName(widget.campaignId).then((name) {
      setState(() {
        campaignName = name;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(campaignName),
        centerTitle: true,
      ),
    );
  }
}

Future<String> _getCampaignName(String campaignId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  try {
    DocumentSnapshot campaignSnapshot =
        await firestore.collection('campaigns').doc(campaignId).get();
    if (campaignSnapshot.exists) {
      return campaignSnapshot['title'];
    } else {
      return "Campaign not found";
    }
  } catch (e) {
    return "Error: $e";
  }
}
