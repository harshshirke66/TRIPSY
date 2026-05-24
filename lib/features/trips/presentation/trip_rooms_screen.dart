import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripsy/core/models/trip_model.dart';
import 'package:tripsy/core/theme/colors.dart';
import 'package:tripsy/core/widgets/glass_container.dart';
import 'package:tripsy/core/widgets/aurora_background.dart';
import 'package:tripsy/core/providers/providers.dart';

class TripRoomsScreen extends ConsumerStatefulWidget {
  const TripRoomsScreen({super.key});

  @override
  ConsumerState<TripRoomsScreen> createState() => _TripRoomsScreenState();
}

class _TripRoomsScreenState extends ConsumerState<TripRoomsScreen> {
  @override
  Widget build(BuildContext context) {
    final tripsState = ref.watch(tripRoomsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: tripsState.when(
                  data: (trips) => _buildTripsList(trips),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: TripsyColors.sunsetOrange),
                  ),
                  error: (err, _) => Center(
                    child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 84.0),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: TripsyColors.sunsetOrange,
                blurRadius: 16,
                spreadRadius: -2,
              )
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _showCreateTripDialog(context),
            backgroundColor: TripsyColors.sunsetOrange,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
        ),
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
            'Trip Rooms',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Collaborate on expenses and itineraries with friends',
            style: TextStyle(
              fontSize: 14,
              color: TripsyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(List<TripRoom> trips) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: TripsyColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'No active trips',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to plan your first group trip!',
              style: TextStyle(fontSize: 13, color: TripsyColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        final memberCount = trip.members.length;
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailScreen(tripId: trip.id),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    trip.coverImage ?? 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=600&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          trip.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          borderRadius: 12,
                          opacity: 0.12,
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: TripsyColors.oceanTeal),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  trip.destination,
                                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.people_alt_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                '$memberCount members',
                                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreateTripDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateTripModal(),
    );
  }
}

class CreateTripModal extends ConsumerStatefulWidget {
  const CreateTripModal({super.key});

  @override
  ConsumerState<CreateTripModal> createState() => _CreateTripModalState();
}

class _CreateTripModalState extends ConsumerState<CreateTripModal> {
  final _titleController = TextEditingController();
  final _destController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();

  final DateTime _startDate = DateTime.now();
  final DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  
  final List<String> _covers = [
    'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1527631746610-bca00a040d60?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&auto=format&fit=crop',
  ];
  int _selectedCoverIdx = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _destController.dispose();
    _descController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        borderRadius: 32,
        opacity: 0.12,
        padding: const EdgeInsets.all(24),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: const BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.all(Radius.circular(2))),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Plan New Expedition',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
              ),
              const SizedBox(height: 16),
              _buildInput(_titleController, 'Trip Title', Icons.title_rounded),
              const SizedBox(height: 12),
              _buildInput(_destController, 'Destination (e.g. Kyoto, Japan)', Icons.location_on_rounded),
              const SizedBox(height: 12),
              _buildInput(_descController, 'Short Description', Icons.description_rounded),
              const SizedBox(height: 12),
              _buildInput(_budgetController, 'Trip Budget (\$)', Icons.monetization_on_rounded, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              const Text('Select Trip Cover Image', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _covers.length,
                  itemBuilder: (context, idx) {
                    final isSel = idx == _selectedCoverIdx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCoverIdx = idx),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: isSel ? Border.all(color: TripsyColors.sunsetOrange, width: 2) : null,
                          image: DecorationImage(image: NetworkImage(_covers[idx]), fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _submitTrip,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: TripsyColors.sunsetGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: TripsyColors.sunsetOrange.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Text('Create Trip Room', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: TripsyColors.textMuted),
        prefixIcon: Icon(icon, color: TripsyColors.textMuted),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: TripsyColors.skyBlue, width: 1.5)),
        fillColor: Colors.white.withValues(alpha: 0.03),
        filled: true,
      ),
    );
  }

  void _submitTrip() {
    if (_titleController.text.isEmpty || _destController.text.isEmpty) return;
    final budget = double.tryParse(_budgetController.text) ?? 500.0;
    
    ref.read(tripRoomsProvider.notifier).createTrip(
      _titleController.text.trim(),
      _descController.text.trim(),
      _destController.text.trim(),
      budget,
      _startDate,
      _endDate,
      _covers[_selectedCoverIdx],
    );
    Navigator.of(context).pop();
  }
}

class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _expenseAmountCtrl = TextEditingController();
  final _expenseDescCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expenseAmountCtrl.dispose();
    _expenseDescCtrl.dispose();
    super.dispose();
  }

  Map<String, double> _calculateBalances(TripRoom trip) {
    double totalSpent = 0;
    Map<String, double> spentByMember = {};
    for (var m in trip.members) {
      spentByMember[m.id] = 0.0;
    }
    
    for (var e in trip.expenses) {
      totalSpent += e.amount;
      spentByMember[e.paidBy] = (spentByMember[e.paidBy] ?? 0.0) + e.amount;
    }

    final share = totalSpent / trip.members.length;
    Map<String, double> balances = {};
    for (var m in trip.members) {
      balances[m.id] = (spentByMember[m.id] ?? 0.0) - share;
    }
    return balances;
  }

  @override
  Widget build(BuildContext context) {
    final tripsState = ref.watch(tripRoomsProvider);
    
    return tripsState.when(
      data: (trips) {
        final trip = trips.firstWhere((t) => t.id == widget.tripId);
        final balances = _calculateBalances(trip);
        final myBalance = balances['current_user_id'] ?? 0.0;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AuroraBackground(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) => [
                _buildSliverAppBar(trip),
              ],
              body: Column(
                children: [
                  Container(
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                      tabs: const [
                        Tab(text: 'Itinerary'),
                        Tab(text: 'Splitwise Expenses'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildItineraryTab(trip),
                        _buildExpensesTab(trip, balances, myBalance),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const Scaffold(body: Center(child: Text('Error loading trip details'))),
    );
  }

  Widget _buildSliverAppBar(TripRoom trip) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          trip.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(trip.coverImage ?? '', fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    TripsyColors.deepSpace.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryTab(TripRoom trip) {
    return Stack(
      children: [
        trip.itinerary.isEmpty
            ? const Center(
                child: Text('No timeline activities yet. Tap + to add.', style: TextStyle(color: TripsyColors.textSecondary)),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 80),
                itemCount: trip.itinerary.length,
                itemBuilder: (context, index) {
                  final item = trip.itinerary[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: TripsyColors.oceanTeal.withValues(alpha: 0.2),
                            ),
                            child: const Center(
                              child: Icon(Icons.explore_rounded, size: 14, color: TripsyColors.oceanTeal),
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  TripsyColors.oceanTeal.withValues(alpha: 0.8),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          borderRadius: 20,
                          opacity: 0.04,
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Day ${item.dayNumber} • ${item.timeOfDay ?? 'All Day'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: TripsyColors.oceanTeal,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                              if (item.description != null && item.description!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(item.description!, style: const TextStyle(fontSize: 12, color: TripsyColors.textSecondary)),
                              ],
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: TripsyColors.oceanTeal,
                  blurRadius: 12,
                  spreadRadius: -2,
                )
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'add_iti',
              mini: true,
              shape: const CircleBorder(),
              onPressed: () => _showAddItineraryDialog(trip),
              backgroundColor: TripsyColors.oceanTeal,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildExpensesTab(TripRoom trip, Map<String, double> balances, double myBalance) {
    final netText = myBalance >= 0 ? 'You are owed' : 'You owe';
    final netColor = myBalance >= 0 ? TripsyColors.activeGreen : TripsyColors.sunsetOrange;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              opacity: 0.05,
              borderSide: BorderSide(color: netColor.withValues(alpha: 0.3), width: 1.5),
              shadows: [
                BoxShadow(
                  color: netColor.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(netText, style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('\$${myBalance.abs().toStringAsFixed(2)}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: netColor)),
                    ],
                  ),
                  Icon(Icons.account_balance_wallet_rounded, size: 40, color: netColor.withValues(alpha: 0.3)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Who owes whom',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: TripsyColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            ..._buildLedgerBreakdown(trip, balances),
            const SizedBox(height: 24),

            const Text(
              'Expense Log',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: TripsyColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            if (trip.expenses.isEmpty)
              const Center(child: Text('No expenditures recorded.', style: TextStyle(color: TripsyColors.textMuted)))
            else
              ...trip.expenses.map((e) {
                final payer = trip.members.firstWhere((m) => m.id == e.paidBy, orElse: () => trip.members.first);
                return GlassContainer(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 16,
                  opacity: 0.03,
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.description, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Paid by ${payer.fullName}', style: const TextStyle(fontSize: 11, color: TripsyColors.textSecondary)),
                        ],
                      ),
                      Text(
                        '\$${e.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: TripsyColors.sunsetOrange,
                  blurRadius: 12,
                  spreadRadius: -2,
                )
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'add_exp',
              mini: true,
              shape: const CircleBorder(),
              onPressed: () => _showAddExpenseDialog(trip),
              backgroundColor: TripsyColors.sunsetOrange,
              child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> _buildLedgerBreakdown(TripRoom trip, Map<String, double> balances) {
    List<Widget> list = [];
    List<MapEntry<String, double>> debtors = [];
    List<MapEntry<String, double>> creditors = [];

    balances.forEach((id, bal) {
      if (bal < -0.01) {
        debtors.add(MapEntry(id, bal));
      } else if (bal > 0.01) {
        creditors.add(MapEntry(id, bal));
      }
    });

    int dIdx = 0;
    int cIdx = 0;

    while (dIdx < debtors.length && cIdx < creditors.length) {
      final debtorId = debtors[dIdx].key;
      final debtorBal = debtors[dIdx].value.abs();

      final creditorId = creditors[cIdx].key;
      final creditorBal = creditors[cIdx].value;

      final payout = debtorBal < creditorBal ? debtorBal : creditorBal;
      
      final dUser = trip.members.firstWhere((m) => m.id == debtorId);
      final cUser = trip.members.firstWhere((m) => m.id == creditorId);

      list.add(
        GlassContainer(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 16,
          opacity: 0.02,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.03)),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz_rounded, color: TripsyColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${dUser.fullName} owes ${cUser.fullName}',
                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '\$${payout.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: TripsyColors.sunsetOrange),
              ),
            ],
          ),
        ),
      );

      if (debtorBal < creditorBal) {
        creditors[cIdx] = MapEntry(creditorId, creditorBal - payout);
        dIdx++;
      } else {
        debtors[dIdx] = MapEntry(debtorId, debtorBal - payout);
        cIdx++;
      }
    }

    if (list.isEmpty) {
      list.add(
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 16,
          opacity: 0.02,
          borderSide: const BorderSide(color: TripsyColors.activeGreen, width: 0.5),
          child: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: TripsyColors.activeGreen, size: 20),
              SizedBox(width: 12),
              Text('Balances are settled!', style: TextStyle(color: TripsyColors.activeGreen, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }
    return list;
  }

  void _showAddItineraryDialog(TripRoom trip) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int day = 1;
    String timeOfDay = 'Morning';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          opacity: 0.12,
          padding: const EdgeInsets.all(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Activity', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Activity Title',
                  hintStyle: const TextStyle(color: TripsyColors.textMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: TripsyColors.oceanTeal)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Activity Description',
                  hintStyle: const TextStyle(color: TripsyColors.textMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: TripsyColors.oceanTeal)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: TripsyColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TripsyColors.oceanTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.isEmpty) return;
                      ref.read(tripRoomsProvider.notifier).addItineraryItem(trip.id, day, timeOfDay, titleCtrl.text.trim(), descCtrl.text.trim(), '');
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showAddExpenseDialog(TripRoom trip) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          opacity: 0.12,
          padding: const EdgeInsets.all(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Log Expense', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _expenseDescCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Description (e.g. Dinner)',
                  hintStyle: const TextStyle(color: TripsyColors.textMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: TripsyColors.sunsetOrange)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _expenseAmountCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Amount (\$)',
                  hintStyle: const TextStyle(color: TripsyColors.textMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: TripsyColors.sunsetOrange)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: TripsyColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TripsyColors.sunsetOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final amount = double.tryParse(_expenseAmountCtrl.text) ?? 0.0;
                      if (_expenseDescCtrl.text.isEmpty || amount <= 0) return;
                      
                      ref.read(tripRoomsProvider.notifier).addExpenseItem(trip.id, _expenseDescCtrl.text.trim(), amount);
                      _expenseDescCtrl.clear();
                      _expenseAmountCtrl.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Log'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
