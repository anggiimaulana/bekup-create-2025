import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/l10n/app_localizations.dart';
import 'package:story_app/services/story_provider.dart';
import 'package:story_app/utils/constansts.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;
  final VoidCallback onBack;

  const StoryDetailScreen({
    super.key,
    required this.storyId,
    required this.onBack,
  });

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStoryDetail();
    });
  }

  Future<void> _loadStoryDetail() async {
    final authProvider = context.read<AuthProvider>();
    final storyProvider = context.read<StoryProvider>();
    if (authProvider.token != null) {
      await storyProvider.getStoryDetail(authProvider.token!, widget.storyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Consumer<StoryProvider>(
        builder: (context, storyProvider, _) {
          if (storyProvider.state == StoryState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryColor,
                ),
              ),
            );
          }

          if (storyProvider.state == StoryState.error ||
              storyProvider.selectedStory == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppConstants.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    storyProvider.errorMessage ?? l10n.error,
                    style: const TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStoryDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final story = storyProvider.selectedStory!;
          final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

          return CustomScrollView(
            slivers: [
              // App bar with image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppConstants.surfaceColor,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  onPressed: widget.onBack,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'story-${story.id}',
                    child: Image.network(
                      story.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppConstants.backgroundColor,
                          child: const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: AppConstants.textSecondaryColor,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppConstants.backgroundColor,
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppConstants.primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppConstants.defaultPadding * 1.5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author info
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppConstants.primaryColor,
                              child: Text(
                                story.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.textPrimaryColor,
                                    ),
                                  ),
                                  Text(
                                    dateFormat.format(story.createdAt),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        Text(
                          l10n.description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          story.description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Location info if available
                        if (story.lat != null && story.lon != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppConstants.backgroundColor,
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: AppConstants.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Location: ${story.lat}, ${story.lon}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
