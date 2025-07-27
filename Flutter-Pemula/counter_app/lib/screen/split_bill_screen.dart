import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/result_card.dart';

final Logger logger = Logger();

class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen>
    with TickerProviderStateMixin {
  int totalBill = 0;
  int jumlahOrang = 0;
  double jumlahPembayaranPerOrang = 0;
  String hasilPembayaran = "";
  List<Map<String, dynamic>> history = [];

  SharedPreferences? pref;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final TextEditingController totalBillController = TextEditingController();
  final TextEditingController jumlahOrangController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  Future<void> _initSharedPreferences() async {
    pref = await SharedPreferences.getInstance();
    await _loadHistory();
    logger.i("SharedPreferences loaded di SplitBillScreen");
  }

  Future<void> _loadHistory() async {
    final historyString = pref?.getString('split_history') ?? '[]';
    setState(() {
      history = List<Map<String, dynamic>>.from(
        (historyString.isNotEmpty) ? [] : [],
      );
    });
  }

  Future<void> _saveToHistory() async {
    final historyItem = {
      'totalBill': totalBill,
      'jumlahOrang': jumlahOrang,
      'perOrang': jumlahPembayaranPerOrang,
      'timestamp': DateTime.now().toIso8601String(),
    };

    history.insert(0, historyItem);
    if (history.length > 10) {
      history.removeLast();
    }

    await pref?.setString('split_history', history.toString());
  }

  @override
  void dispose() {
    totalBillController.dispose();
    jumlahOrangController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _hitungPembayaran() {
    setState(() {
      totalBill = int.tryParse(totalBillController.text) ?? 0;
      jumlahOrang = int.tryParse(jumlahOrangController.text) ?? 0;

      logger.d("Input total: $totalBill, jumlah orang: $jumlahOrang");

      if (jumlahOrang > 0 && totalBill > 0) {
        jumlahPembayaranPerOrang = totalBill / jumlahOrang;
        hasilPembayaran =
            "Rp ${_formatCurrency(jumlahPembayaranPerOrang.toInt())}";

        _saveToHistory();
        _animationController.forward().then((_) {
          _animationController.reverse();
        });

        pref?.setInt("totalBill", totalBill);
        logger.i(
          "Pembayaran dihitung: $hasilPembayaran disimpan ke SharedPreferences",
        );

        _showSnackBar("Pembayaran berhasil dihitung!", isError: false);
      } else {
        hasilPembayaran = "Input tidak valid";
        logger.w("Input tidak valid: total=$totalBill, orang=$jumlahOrang");
        _showSnackBar("Mohon masukkan nilai yang valid", isError: true);
      }
    });
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pref = await SharedPreferences.getInstance();
                  await pref.clear();
                  logger.i("User logout, SharedPreferences dibersihkan");

                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              const LoginScreen(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _clearForm() {
    totalBillController.clear();
    jumlahOrangController.clear();
    setState(() {
      totalBill = 0;
      jumlahOrang = 0;
      hasilPembayaran = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Split Bill Calculator"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SplitBillHeader(),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: totalBillController,
                        hintText: "Total tagihan (Rp)",
                        prefixIcon: Icons.monetization_on,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          logger.d("Input total bill: $value");
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: jumlahOrangController,
                        hintText: "Jumlah orang",
                        prefixIcon: Icons.group,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          logger.d("Input jumlah orang: $value");
                        },
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              onPressed: _hitungPembayaran,
                              text: "Hitung",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomButton(
                              onPressed: _clearForm,
                              text: "Reset",
                              isSecondary: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ScaleTransition(
                scale: _scaleAnimation,
                child: ResultCard(
                  result: hasilPembayaran,
                  totalBill: totalBill,
                  jumlahOrang: jumlahOrang,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplitBillHeader extends StatelessWidget {
  const SplitBillHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            "Hitung Split Bill",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Masukkan total tagihan dan jumlah orang untuk menghitung pembayaran per orang",
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
