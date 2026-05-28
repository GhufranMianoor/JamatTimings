import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerMasjidList extends StatelessWidget {
  const ShimmerMasjidList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 150, height: 16, color: Colors.white),
                          const SizedBox(width: 8, height: 8),
                          Container(width: 100, height: 12, color: Colors.white),
                          const SizedBox(width: 8, height: 8),
                          Container(width: 200, height: 12, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
