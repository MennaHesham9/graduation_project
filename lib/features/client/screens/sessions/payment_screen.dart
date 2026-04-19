import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // 0 = card, 1 = digital wallet
  final _cardNumberController    = TextEditingController();
  final _expiryController        = TextEditingController();
  final _cvvController           = TextEditingController();
  final _cardHolderController    = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
                      ),
                      child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Payment', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      Text('Complete your booking securely', style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A))),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Amount card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Amount to Pay', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 4),
                          const Text('\$75.00', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 14),
                          _PriceRow(label: 'Session Price', value: '\$75.00'),
                          const Divider(color: Colors.white24, height: 16),
                          _PriceRow(label: 'Platform Fee', value: '\$0.00'),
                          const Divider(color: Colors.white24, height: 16),
                          _PriceRow(label: 'Total', value: '\$75.00', bold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Payment method ──
                    const Text('Payment Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),

                    _PaymentMethodTile(
                      icon: Icons.credit_card_outlined,
                      label: 'Credit / Debit Card',
                      selected: _selectedMethod == 0,
                      onTap: () => setState(() => _selectedMethod = 0),
                    ),
                    const SizedBox(height: 10),
                    _PaymentMethodTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Digital Wallet',
                      selected: _selectedMethod == 1,
                      onTap: () => setState(() => _selectedMethod = 1),
                    ),
                    const SizedBox(height: 20),

                    // ── Card details (shown when card selected) ──
                    if (_selectedMethod == 0)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Card Number'),
                            _CardField(controller: _cardNumberController, hint: '1234 5678 9012 3456', icon: Icons.credit_card_outlined),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _FieldLabel('Expiry Date'),
                                      _CardField(controller: _expiryController, hint: 'MM/YY', icon: null),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _FieldLabel('CVV'),
                                      _CardField(controller: _cvvController, hint: '123', icon: null),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _FieldLabel('Cardholder Name'),
                            _CardField(controller: _cardHolderController, hint: 'SARAH JOHNSON', icon: null),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // ── Secure badge ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FBF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB8EDD0)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.security_outlined, color: Color(0xFF2E9E6B), size: 20),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Secure Payment', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2E9E6B))),
                              Text('Your payment information is encrypted and secure', style: TextStyle(fontSize: 11, color: Color(0xFF2E9E6B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Pay button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock_outline, color: Colors.white, size: 18),
                  label: const Text('Pay Now - \$75.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _PriceRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 14 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: Colors.white,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? const Color(0xFF9B59B6) : const Color(0xFFE8E8F0), width: selected ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : const Color(0xFFF0F2F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: selected ? Colors.white : const Color(0xFF8A8A9A)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)))),
            Radio<int>(
              value: selected ? 1 : 0,
              groupValue: 1,
              onChanged: (_) => onTap(),
              activeColor: const Color(0xFF9B59B6),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
    );
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;

  const _CardField({required this.controller, required this.hint, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8F0)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFB0B0C0), fontSize: 13),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFB0B0C0), size: 18) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}