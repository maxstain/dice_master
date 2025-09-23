import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeletonScreen extends StatelessWidget {
  const HomeSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campaign Lobby")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4, // show 4 skeleton cards
        itemBuilder: (ctx, i) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: _buildShimmerLine(width: 140, height: 16),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(width: 100),
                  _buildShimmerLine(width: 60),
                ],
              ),
              trailing: _buildShimmerCircle(size: 24),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLine({double width = 120, double height = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade600,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCircle({double size = 24}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: Container(
        height: size,
        width: size,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
