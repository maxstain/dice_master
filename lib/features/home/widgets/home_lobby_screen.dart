import 'package:dice_master/models/campaignWithMeta.dart';
import 'package:flutter/material.dart';

import '../../campaign/campaign_screen.dart';

class HomeLobbyScreen extends StatelessWidget {
  final List<CampaignWithMeta> campaigns;

  const HomeLobbyScreen({super.key, required this.campaigns});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campaign Lobby")),
      body: ListView.builder(
        itemCount: campaigns.length,
        itemBuilder: (ctx, i) {
          final cwm = campaigns[i];
          return Card(
            child: ListTile(
              title: Text(cwm.campaign.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<String>(
                    stream: cwm.hostNameStream,
                    builder: (ctx, snap) =>
                        Text("Host: ${snap.data ?? cwm.campaign.hostId}"),
                  ),
                  StreamBuilder<int>(
                    stream: cwm.playerCountStream,
                    builder: (ctx, snap) => Text("Players: ${snap.data ?? 0}"),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CampaignScreen(campaignId: cwm.campaign.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
