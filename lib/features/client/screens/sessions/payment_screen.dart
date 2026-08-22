import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../booking/providers/booking_provider.dart';
import 'booking_confirmed_screen.dart';

class PaymentScreen extends StatefulWidget {
  final UserModel coach;
  const PaymentScreen({super.key, required this.coach});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'icon': Icons.credit_card, 'label': 'Credit / Debit Card', 'sub': '**** **** **** 4242'},
    {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet Balance', 'sub': 'Available: \$120.00'},
    {'icon': Icons.paypal_outlined, 'label': 'PayPal', 'sub': 'Pay via PayPal'},
  ];

  static const double _platformFeeRate = 0.10; // 10%

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BookingProvider>().clearError();
    });
  }

  /// The coach's session price (what gets sent to the coach).
  double _sessionPrice(BookingProvider provider) {
    final plan = provider.selectedPlanType ?? '';
    final coach = widget.coach;
    final isVideo = plan.contains('video');
    if (provider.isPackagePlan) {
      return provider.requiredSlots == 8
          ? coach.package8Price
          : coach.package4Price;
    }
    return isVideo ? coach.singleVideoPrice : coach.singleAudioPrice;
  }

  /// Platform fee on top of the session price.
  double _platformFee(double sessionPrice) =>
      double.parse((sessionPrice * _platformFeeRate).toStringAsFixed(2));

  /// Total charged to the client.
  double _totalPrice(double sessionPrice) =>
      double.parse((sessionPrice + _platformFee(sessionPrice)).toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final client = context.read<AuthProvider>().user;
    final currency = widget.coach.currency ?? 'USD';

    final sessionPrice = _sessionPrice(provider);
    final platformFee = _platformFee(sessionPrice);
    final total = _totalPrice(sessionPrice);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Payment',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Booking Summary ──────────────────────────────────────────
          _SectionTitle('Booking Summary'),
          const SizedBox(height: 12),
          _SummaryCard(
            provider: provider,
            coach: widget.coach,
            currency: currency,
            sessionPrice: sessionPrice,
            platformFee: platformFee,
            total: total,
          ),
          const SizedBox(height: 24),
          // ── Payment Method ───────────────────────────────────────────
          _SectionTitle('Payment Method'),
          const SizedBox(height: 12),
          ...List.generate(
            _paymentMethods.length,
                (i) => _PaymentMethodTile(
              icon: _paymentMethods[i]['icon'] as IconData,
              label: _paymentMethods[i]['label'] as String,
              sub: _paymentMethods[i]['sub'] as String,
              selected: _selectedPaymentMethod == i,
              onTap: () => setState(() => _selectedPaymentMethod = i),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: _BottomPayBar(
        total: total,
        currency: currency,
        isLoading: provider.isLoading,
        error: provider.error,
        onPay: () async {
          provider.clearError();

          // Only the session price (excluding platform fee) goes to the coach.
          const mockPaymentRef = 'mock_pay_ref_001';

          final success = await provider.confirmBooking(
            clientId: client?.uid ?? '',
            clientName: client?.fullName ?? '',
            coachId: widget.coach.uid,
            coachName: widget.coach.fullName ?? '',
            price: sessionPrice, // ← coach receives only the session price
            currency: currency,
            durationMinutes: widget.coach.sessionDuration ?? 60,
            clientTimezone: client?.timezone ?? 'UTC',
            paymentRef: mockPaymentRef,
          );

          if (success && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BookingConfirmedScreen(coach: widget.coach),
              ),
            );
          }
        },
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
}

class _SummaryCard extends StatelessWidget {
  final BookingProvider provider;
  final UserModel coach;
  final String currency;
  final double sessionPrice;
  final double platformFee;
  final double total;

  const _SummaryCard({
    required this.provider,
    required this.coach,
    required this.currency,
    required this.sessionPrice,
    required this.platformFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final plan = provider.selectedPlanType ?? '';
    final isPackage = provider.isPackagePlan;
    final isVideo = plan.contains('video');
    final planLabel = isPackage
        ? '${provider.requiredSlots}-Session ${isVideo ? 'Video' : 'Audio'} Package'
        : 'Single ${isVideo ? 'Video' : 'Audio'} Session';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _Row('Coach', coach.fullName ?? ''),
          _Row('Plan', planLabel),
          _Row(
            'Date(s)',
            provider.selectedSlots
                .map((d) => DateFormat('MMM d, h:mm a').format(d.toLocal()))
                .join('\n'),
          ),
          const Divider(height: 24),

          // ── Price breakdown ──────────────────────────────────────────
          _PriceRow(
            label: 'Session Price',
            value: '$currency ${sessionPrice.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Platform Fee (10%)',
            value: '$currency ${platformFee.toStringAsFixed(2)}',
            valueColor: Colors.grey.shade600,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _PriceRow(
            label: 'Total',
            value: '$currency ${total.toStringAsFixed(2)}',
            labelStyle: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
            valueStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF4A90D9)),
          ),

          const SizedBox(height: 10),

          // ── Disclosure note ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: Color(0xFF4A90D9)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${coach.fullName?.split(' ').first ?? 'The coach'} receives $currency ${sessionPrice.toStringAsFixed(2)}. '
                        'The platform fee covers payment processing and support.',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF4A90D9), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic label + value row for the booking details section.
class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13)),
        ),
      ],
    ),
  );
}

/// Price breakdown row (session price / fee / total).
class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: labelStyle ??
                const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value,
            style: valueStyle ??
                TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: valueColor ?? Colors.black87)),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF4A90D9) : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? const Color(0xFF4A90D9) : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(sub,
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFF4A90D9)),
          ],
        ),
      ),
    );
  }
}

class _BottomPayBar extends StatelessWidget {
  final double total;
  final String currency;
  final bool isLoading;
  final String? error;
  final VoidCallback onPay;
  const _BottomPayBar({
    required this.total,
    required this.currency,
    required this.isLoading,
    required this.error,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90D9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: isLoading ? null : onPay,
              child: isLoading
                  ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : Text(
                'Pay $currency ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}