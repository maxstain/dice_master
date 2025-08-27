import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/models/campaign.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Campaign> _getCampaign(String campaignId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot campaignSnapshot =
          await firestore.collection('campaigns').doc(campaignId).get();

      if (campaignSnapshot.exists) {
        return Campaign.fromJson(
            campaignSnapshot.data() as Map<String, dynamic>);
      } else {
        return Campaign.empty();
      }
    } catch (e) {
      print('Error fetching campaign: $e');
      return Campaign.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Campaign>(
      future: _getCampaign(widget.campaignId),
      builder: (context, snapshot) {
        // 🔄 Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Error state
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Error loading campaign")),
          );
        }

        // 📦 Loaded state
        final campaign = snapshot.data ?? Campaign.empty();

        if (campaign.isEmpty()) {
          return const Scaffold(
            body: Center(child: Text("Campaign not found")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(campaign.title),
            centerTitle: true,
          ),
          body: const SingleChildScrollView(
            child: Column(
              children: [],
            ),
          ),
        );
      },
    );
  }
}
