import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/l10n/app_localizations.dart';
import 'package:story_app/services/story_provider.dart';
import 'package:story_app/utils/constansts.dart';
import '../models/story.dart';
import '../providers/auth_provider.dart';
import '../widgets/story_card.dart';

class StoryListScreen extends StatefulWidget {
  final Function(Story) onStoryTap;
  final VoidCallback onAddStory;
  final VoidCallback onLogout;

  const StoryListScreen({
    super.key,
    required this.onStoryTap,
    required this.onAddStory,
    required this.onLogout,
  });

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStories();
    });
  }

  Future<void> _loadStories() async {
    final authProvider = context.read<AuthProvider>();
    final storyProvider = context.read<StoryProvider>();
    if (authProvider.token != null) {
      await storyProvider.getStories(authProvider.token!);
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceColor,
        elevation: 0,
        title: Text(
          l10n.stories,
          style: const TextStyle(
            color: AppConstants.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppConstants.primaryColor),
            onPressed: _handleLogout,
            tooltip: l10n.logout,
          ),
        ],
      ),
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

          if (storyProvider.state == StoryState.error) {
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
                    onPressed: _loadStories,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (storyProvider.stories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: AppConstants.textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noData,
                    style: const TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadStories,
            color: AppConstants.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: storyProvider.stories.length,
              itemBuilder: (context, index) {
                final story = storyProvider.stories[index];
                return StoryCard(
                  story: story,
                  onTap: () => widget.onStoryTap(story),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAddStory,
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.addStory, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
