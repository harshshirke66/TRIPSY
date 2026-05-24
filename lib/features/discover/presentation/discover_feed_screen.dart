import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripsy/core/models/story_model.dart';
import 'package:tripsy/core/models/trip_model.dart';
import 'package:tripsy/core/theme/colors.dart';
import 'package:tripsy/core/widgets/glass_container.dart';
import 'package:tripsy/core/providers/providers.dart';
import 'package:tripsy/features/chat/presentation/chat_screens.dart';

class DiscoverFeedScreen extends ConsumerStatefulWidget {
  const DiscoverFeedScreen({super.key});

  @override
  ConsumerState<DiscoverFeedScreen> createState() => _DiscoverFeedScreenState();
}

class _DiscoverFeedScreenState extends ConsumerState<DiscoverFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<Marker> _markers = {};
  bool _showMapDetail = false;
  dynamic _selectedMapUser;

  // Mock markers for nearby explorers
  void _initMapMarkers() {
    _markers.addAll([
      Marker(
        markerId: const MarkerId('mark_lena'),
        position: const LatLng(-8.4095, 115.1889), // Ubud, Bali
        infoWindow: const InfoWindow(title: 'Elena Rostova'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () {
          setState(() {
            _selectedMapUser = {
              'name': 'Elena Rostova',
              'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&auto=format&fit=crop',
              'location': 'Ubud, Bali',
              'interest': 'Yoga & Shrines',
              'id': 'user_lena',
            };
            _showMapDetail = true;
          });
        },
      ),
      Marker(
        markerId: const MarkerId('mark_leo'),
        position: const LatLng(35.6762, 139.6503), // Tokyo
        infoWindow: const InfoWindow(title: 'Leo Dubois'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        onTap: () {
          setState(() {
            _selectedMapUser = {
              'name': 'Leo Dubois',
              'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600&auto=format&fit=crop',
              'location': 'Shinjuku, Tokyo',
              'interest': 'Photography Trek',
              'id': 'user_leo',
            };
            _showMapDetail = true;
          });
        },
      ),
      Marker(
        markerId: const MarkerId('mark_amara'),
        position: const LatLng(-8.3494, 116.0381), // Gili T
        infoWindow: const InfoWindow(title: 'Amara Kante'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () {
          setState(() {
            _selectedMapUser = {
              'name': 'Amara Kante',
              'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop',
              'location': 'Gili Islands',
              'interest': 'Scuba Diving',
              'id': 'user_amara',
            };
            _showMapDetail = true;
          });
        },
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initMapMarkers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storiesState = ref.watch(storyListProvider);
    final tripsState = ref.watch(tripRoomsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(decoration: const BoxDecoration(gradient: TripsyColors.darkSpaceGradient)),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 54),
              _buildHeader(),
              
              // Segment Control Tab (Feed / Explorer Map)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: TripsyColors.sunsetGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: TripsyColors.textSecondary,
                    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Trending Feed'),
                      Tab(text: 'Explorer Map'),
                    ],
                  ),
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(), // avoids map conflicts
                  children: [
                    // Feed screen
                    _buildFeedTab(storiesState, tripsState),

                    // Map Screen
                    _buildMapTab(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore World',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
          ),
          SizedBox(height: 4),
          Text(
            'Discover trips and active travelers worldwide',
            style: TextStyle(fontSize: 14, color: TripsyColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedTab(AsyncValue<List<Story>> storiesState, AsyncValue<List<TripRoom>> tripsState) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Story reels
          storiesState.when(
            data: (stories) => _buildStoryReel(stories),
            loading: () => const SizedBox(height: 110, child: Center(child: CircularProgressIndicator())),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Trending Expeditions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),

          // Active Trip Cards (Airbnb Style)
          tripsState.when(
            data: (trips) => _buildTripCarousel(trips),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Popular Destinations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          _buildDestinationsList(),
        ],
      ),
    );
  }

  Widget _buildStoryReel(List<Story> stories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Live Stories',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: TripsyColors.textSecondary),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return GestureDetector(
                onTap: () {
                  // View full screen story
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StoryViewerScreen(stories: stories, initialIndex: index),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: TripsyColors.sunsetGradient,
                          boxShadow: [
                            BoxShadow(
                              color: TripsyColors.sunsetOrange.withValues(alpha: 0.35),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(story.profile?.avatarUrl ?? ''),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        story.profile?.fullName.split(' ').first ?? 'User',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTripCarousel(List<TripRoom> trips) {
    if (trips.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 220,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: TripsyColors.sunsetOrange.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipPath(
                clipper: TicketClipper(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(trip.coverImage ?? '', fit: BoxFit.cover),
                    // Dark scrim gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.4),
                            Colors.black.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                    // Dashed line dividing the card at 72% height
                    Positioned(
                      bottom: 74,
                      left: 14,
                      right: 14,
                      child: Row(
                        children: List.generate(
                          18,
                          (index) => Expanded(
                            child: Container(
                              color: index % 2 == 0 ? Colors.transparent : Colors.white.withValues(alpha: 0.25),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Header budget badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          '\$${trip.budget?.toInt() ?? 0} Budget',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TripsyColors.peachBurn),
                        ),
                      ),
                    ),
                    // Details text
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 12, color: TripsyColors.oceanTeal),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  trip.destination,
                                  style: const TextStyle(fontSize: 12, color: TripsyColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDestinationsList() {
    final destinations = [
      {'name': 'Bali, Indonesia', 'image': 'https://images.unsplash.com/photo-1527631746610-bca00a040d60?w=600&auto=format&fit=crop', 'trips': '14 active trips'},
      {'name': 'Kyoto, Japan', 'image': 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=600&auto=format&fit=crop', 'trips': '22 active trips'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: destinations.map((d) {
          return Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(d['image']!, fit: BoxFit.cover),
                  Container(color: Colors.black.withValues(alpha: 0.4)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(d['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(d['trips']!, style: const TextStyle(fontSize: 12, color: TripsyColors.textSecondary)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMapTab() {
    return Stack(
      children: [
        // Map implementation
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(-8.4095, 115.1889), // Bali Default
            zoom: 8.0,
          ),
          markers: _markers,
          mapType: MapType.normal,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),

        // Detail Glass overlay card if marker is selected
        if (_showMapDetail && _selectedMapUser != null)
          Positioned(
            bottom: 96,
            left: 20,
            right: 20,
            child: GlassContainer(
              borderRadius: 24,
              opacity: 0.1,
              borderSide: const BorderSide(
                color: TripsyColors.oceanTeal,
                width: 1.5,
              ),
              shadows: [
                BoxShadow(
                  color: TripsyColors.oceanTeal.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(_selectedMapUser['avatar']),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedMapUser['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedMapUser['location']} • ${_selectedMapUser['interest']}',
                          style: const TextStyle(fontSize: 12, color: TripsyColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatId: 'chat_${_selectedMapUser['id']}',
                            title: _selectedMapUser['name'],
                            avatarUrl: _selectedMapUser['avatar'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: TripsyColors.sunsetGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Say Hi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// Handcrafted Travel Ticket Clipper
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    
    // Add semicircular notch on the left at 72% height
    final leftCut = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(0, size.height * 0.72), radius: 10),
        -math.pi / 2,
        math.pi,
      );
    // Add semicircular notch on the right at 72% height
    final rightCut = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(size.width, size.height * 0.72), radius: 10),
        math.pi / 2,
        math.pi,
      );

    return Path.combine(
      PathOperation.difference,
      Path.combine(PathOperation.difference, path, leftCut),
      rightCut,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Fullscreen Story Viewer
class StoryViewerScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewerScreen({super.key, required this.stories, required this.initialIndex});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  double _percent = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _startStoryTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _percent = 0.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_percent < 1.0) {
          _percent += 0.01;
        } else {
          _timer?.cancel();
          _nextStory();
        }
      });
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startStoryTimer();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Story Image background
          Image.network(story.mediaUrl, fit: BoxFit.cover),

          // Story top headers & user info
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Story Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: List.generate(widget.stories.length, (index) {
                      double progress = 0.0;
                      if (index < _currentIndex) {
                        progress = 1.0;
                      } else if (index == _currentIndex) {
                        progress = _percent;
                      }
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            color: Colors.white,
                            minHeight: 3,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                // Story owner header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(story.profile?.avatarUrl ?? ''),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.profile?.fullName ?? '',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (story.locationName != null)
                            Text(
                              story.locationName!,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                            ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                ),
                
                const Spacer(),

                // Captions
                if (story.caption != null)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GlassContainer(
                      borderRadius: 16,
                      opacity: 0.1,
                      child: Text(
                        story.caption!,
                        style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
