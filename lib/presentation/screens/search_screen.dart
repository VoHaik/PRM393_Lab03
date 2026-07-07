import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/publication.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';
import '../bloc/analysis/analysis_bloc.dart';
import '../bloc/analysis/analysis_event.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _quickTopics = [
    'Artificial Intelligence',
    'Cybersecurity',
    'Blockchain',
    'Data Science',
  ];

  void _triggerSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    _searchController.text = keyword;
    
    // Dispatch search
    context.read<SearchBloc>().add(SearchTopicEvent(keyword));
    
    // Proactively pre-fetch trends and dashboard for this keyword to avoid loading delay when switching tabs
    context.read<AnalysisBloc>().add(FetchAnalysisEvent(keyword));
    context.read<DashboardBloc>().add(FetchDashboardEvent(keyword));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppTheme.primaryNeon, AppTheme.secondaryNeon],
                    ).createShader(bounds),
                    child: const FaIcon(
                      FontAwesomeIcons.graduationCap,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Scientia Analytics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Comprehensive bibliometric analysis platform',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                controller: _searchController,
                onSubmitted: _triggerSearch,
                decoration: InputDecoration(
                  hintText: 'Search topic (e.g. Machine Learning)...',
                  prefixIcon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryNeon),
                    onPressed: () => _triggerSearch(_searchController.text),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Topics Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickTopics.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final topic = _quickTopics[index];
                    return GestureDetector(
                      onTap: () => _triggerSearch(topic),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: AppTheme.glassBox(
                          color: AppTheme.darkCardBackground.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          topic,
                          style: const TextStyle(
                            color: AppTheme.primaryNeon,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Results Label
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchSuccess) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'Results for "${state.keyword}"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Main content body
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.magnifyingGlassChart,
                              size: 64,
                              color: AppTheme.borderNeon,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Search for a topic above or tap a quick chip to start analyzing publications.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is SearchLoading) {
                      return _buildShimmerLoader();
                    }

                    if (state is SearchFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppTheme.accentRose,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _triggerSearch(_searchController.text),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is SearchSuccess) {
                      if (state.publications.isEmpty) {
                        return const Center(
                          child: Text(
                            'No publications found. Try another search query.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: state.publications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pub = state.publications[index];
                          return _buildPublicationCard(pub);
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPublicationCard(Publication pub) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/detail', extra: pub);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                pub.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Journal Source
              if (pub.journal != null)
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.bookOpen, size: 12, color: AppTheme.primaryNeon),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pub.journal!.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),

              // Authors List
              if (pub.authors.isNotEmpty)
                Text(
                  pub.authors.map((a) => a.displayName).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 12),

              // Badges footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Year Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.borderNeon.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pub.publicationYear.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Citations count
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.quoteLeft,
                        size: 12,
                        color: AppTheme.secondaryNeon,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${pub.citedByCount} Citations',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryNeon,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkCardBackground,
      highlightColor: AppTheme.borderNeon,
      child: ListView.separated(
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.darkCardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}
