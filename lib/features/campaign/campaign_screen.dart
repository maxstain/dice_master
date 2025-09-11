import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dice_master/core/widgets/ThemedIconButton.dart';
import 'package:dice_master/features/campaign/views/characters.dart';
import 'package:dice_master/features/campaign/views/combat.dart';
import 'package:dice_master/features/campaign/views/dashboard.dart';
import 'package:dice_master/features/campaign/views/sessions.dart';
import 'package:dice_master/models/campaign.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CampaignScreen extends StatefulWidget {
  final String campaignId;

  const CampaignScreen({super.key, required this.campaignId});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  late final PageController _pageController;
  final int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 🔥 Campaign document stream
  Stream<Campaign> _campaignStream(String campaignId) {
    return FirebaseFirestore.instance
        .collection('campaigns')
        .doc(campaignId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Campaign.fromJson(snapshot.data() as Map<String, dynamic>);
      } else {
        return Campaign.empty();
      }
    });
  }

  // 🔥 Players subcollection stream
  Stream<QuerySnapshot<Map<String, dynamic>>> _playersStream(
      String campaignId) {
    return FirebaseFirestore.instance
        .collection('campaigns')
        .doc(campaignId)
        .collection('players')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Campaign>(
      stream: _campaignStream(widget.campaignId),
      builder: (context, campaignSnapshot) {
        if (campaignSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (campaignSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Error loading campaign")),
          );
        }

        final campaign = campaignSnapshot.data ?? Campaign.empty();

        if (campaign.isEmpty()) {
          return const Scaffold(
            body: Center(child: Text("Campaign not found")),
          );
        }

        if (campaign.hostId == FirebaseAuth.instance.currentUser?.uid) {
          return Scaffold(
            appBar: AppBar(),
            body: Row(
              children: [
                Container(
                  color: Colors.black38,
                  width: 300,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/Logo-removebg-preview.png",
                            width: 100,
                            height: 100,
                          ),
                          const Text(
                            "Dice Master",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ThemedIconButton(
                              icon: const Icon(
                                Icons.home,
                                color: Colors.white,
                                size: 30,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                _pageController.jumpToPage(0);
                              },
                              text: 'Dashboard',
                            ),
                            const SizedBox(height: 8.0), // Added for spacing
                            ThemedIconButton(
                              icon: const Icon(
                                Icons.group, // Icon for Characters
                                color: Colors.white,
                                size: 30,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                _pageController
                                    .jumpToPage(1); // Index for CharactersView
                              },
                              text: 'Characters',
                            ),
                            const SizedBox(height: 8.0), // Added for spacing
                            ThemedIconButton(
                              icon: const Icon(
                                Icons.list_alt, // Icon for Sessions
                                color: Colors.white,
                                size: 30,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                _pageController
                                    .jumpToPage(2); // Index for SessionsView
                              },
                              text: 'Sessions',
                            ),
                            const SizedBox(height: 8.0), // Added for spacing
                            ThemedIconButton(
                              icon: const Icon(
                                Icons.shield_outlined, // Icon for Combat
                                color: Colors.white,
                                size: 30,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                _pageController
                                    .jumpToPage(3); // Index for CombatsView
                              },
                              text: 'Combat',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: [
                      DashboardView(
                        campaign: campaign,
                        players: _playersStream(widget.campaignId),
                      ),
                      CharactersView(
                        players: _playersStream(widget.campaignId),
                      ),
                      const SessionsView(),
                      const CombatsView()
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(campaign.title),
              centerTitle: true,
            ),
            body: CharactersView(players: _playersStream(widget.campaignId)),
          );
        }
      },
    );
  }
}
