import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'enum/enum.dart';
import 'screens/rider_screen.dart';
import 'screens/tracking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Define active user role on launch (defaults to UserRole.customer)
  const activeRole = UserRole.customer;

  runApp(const LogisticoApp(userRole: activeRole));
}

/// Root Application widget with user-role based navigation.
class LogisticoApp extends StatelessWidget {
  final UserRole userRole;

  const LogisticoApp({super.key, this.userRole = UserRole.customer});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logistico Logistics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A6B4A),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: RoleBasedRootScreen(initialRole: userRole),
    );
  }
}

/// Root screen that handles navigation based on the [UserRole] enum.
/// Uses [IndexedStack] to ensure continuous background tracking when switching views.
class RoleBasedRootScreen extends StatefulWidget {
  final UserRole initialRole;

  const RoleBasedRootScreen({super.key, required this.initialRole});

  @override
  State<RoleBasedRootScreen> createState() => _RoleBasedRootScreenState();
}

class _RoleBasedRootScreenState extends State<RoleBasedRootScreen> {
  late UserRole _currentRole;
  // late final RiderLocationSimulator _simulator;

  // static const List<LatLng> _deliveryRoute = [
  //   LatLng(6.596016, 3.355065),
  //   LatLng(6.5968, 3.3538),
  //   LatLng(6.5960, 3.3500),
  //   LatLng(6.5952, 3.3460),
  //   LatLng(6.5948, 3.3430),
  //   LatLng(6.594300, 3.340440),
  // ];

  @override
  void initState() {
    super.initState();
    _currentRole = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _currentRole == UserRole.customer ? 0 : 1;

    return Scaffold(
      body: IndexedStack(
        index: activeIndex,
        children: const [TrackingScreen(), RiderScreen()],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildRoleButton(
                    role: UserRole.customer,
                    icon: Icons.location_searching_rounded,
                    label: 'Customer (Tracking)',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRoleButton(
                    role: UserRole.rider,
                    icon: Icons.delivery_dining_rounded,
                    label: 'Rider View',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required UserRole role,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentRole == role;
    final primaryColor = role == UserRole.customer
        ? const Color(0xFFE87C3E)
        : const Color(0xFF1A6B4A);
    final activeBgColor = role == UserRole.customer
        ? const Color(0xFFFFF3EC)
        : const Color(0xFFE8F5EE);

    final color = isSelected ? primaryColor : const Color(0xFF888888);

    return InkWell(
      onTap: () {
        if (_currentRole != role) {
          setState(() => _currentRole = role);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
