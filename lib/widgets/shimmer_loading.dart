import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerMasjidList extends StatelessWidget {
  const ShimmerMasjidList({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          child: Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
            highlightColor: colorScheme.surface.withValues(alpha: 0.95),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: double.infinity,
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 16,
                            color: colorScheme.onSurface.withValues(alpha: 0.08),
                          ),
                          const SizedBox(width: 8, height: 8),
                          Container(
                            width: 100,
                            height: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.06),
                          ),
                          const SizedBox(width: 8, height: 8),
                          Container(
                            width: 200,
                            height: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.06),
                          ),
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
