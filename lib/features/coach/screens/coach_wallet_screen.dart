// lib/features/coach/screens/coach_wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../services/wallet_service.dart';

class CoachWalletScreen extends StatefulWidget {
  const CoachWalletScreen({super.key});

  @override
  State<CoachWalletScreen> createState() => _CoachWalletScreenState();
}

class _CoachWalletScreenState extends State<CoachWalletScreen> {
  final WalletService _service = WalletService();
  final String? _coachId = FirebaseAuth.instance.currentUser?.uid;

  bool _showAll = false;

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  String _formatDate(DateTime dt) {
    return DateFormat('MMM d, yyyy').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    if (_coachId == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      body: Column(
        children: [

          _buildHeader(context),
          Expanded(
            child: StreamBuilder<WalletSummary>(
              stream: _service.summaryStream(_coachId!),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Could not load wallet data.\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF6A7282)),
                    ),
                  );
                }
                final summary = snap.data ??
                    const WalletSummary(
                      availableBalance: 0,
                      thisMonthEarnings: 0,
                      totalEarnings: 0,
                      thisMonthSessions: 0,
                      totalSessions: 0,
                      transactions: [],
                    );
                return _buildBody(context, summary);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 10)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF101828)),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Wallet & Payments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF101828))),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WalletSummary summary) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.95, -1.0),
          end: Alignment(0.95, 1.0),
          colors: [Color(0xFFFAF5FF), Color(0xFFEFF6FF), Color(0xFFFDF2F8)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          _buildBalanceCard(context, summary),
          const SizedBox(height: 20),
          _buildStatsRow(summary),
          const SizedBox(height: 20),
          _buildBankAccountCard(context),
          const SizedBox(height: 20),
          _buildTransactionsCard(context, summary),
        ],
      ),
    );
  }

  // ─── Balance Card ──────────────────────────────────────────────────────────

  Widget _buildBalanceCard(BuildContext context, WalletSummary summary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.87, -1.0),
          end: Alignment(0.87, 1.0),
          colors: [Color(0xFF00C950), Color(0xFF00BC7D)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 50, offset: const Offset(0, 25))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Balance',
                  style: TextStyle(fontSize: 14, color: Color(0xE6FFFFFF), fontWeight: FontWeight.w400)),
              Icon(Icons.account_balance_wallet_outlined, size: 20, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatCurrency(summary.availableBalance),
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            '${summary.totalSessions} session${summary.totalSessions == 1 ? '' : 's'} total',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showWithdrawSheet(context, summary),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_outlined, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Withdraw to Bank',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(WalletSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'This Month',
            value: _formatCurrency(summary.thisMonthEarnings),
            sub: '${summary.thisMonthSessions} sessions',
            labelColor: const Color(0xFF00A63E),
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: 'Total Earned',
            value: _formatCurrency(summary.totalEarnings),
            sub: '${summary.totalSessions} sessions',
            labelColor: const Color(0xFF155DFC),
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String sub,
    required Color labelColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 10)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: labelColor),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: labelColor)),
          ]),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 12, color: Color(0xFF6A7282))),
        ],
      ),
    );
  }

  // ─── Bank Account Card ──────────────────────────────────────────────────────

  Widget _buildBankAccountCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 10)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bank Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF101828))),
              GestureDetector(
                onTap: () => _showUpdateBankSheet(context),
                child: const Icon(Icons.add_circle_outline_rounded, size: 20, color: Color(0xFF101828)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.75, -1.0),
                end: Alignment(0.75, 1.0),
                colors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank of America',
                    style: TextStyle(fontSize: 14, color: Color(0xCCFFFFFF))),
                SizedBox(height: 8),
                Text('\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 4532',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                SizedBox(height: 8),
                Text('Account Holder',
                    style: TextStyle(fontSize: 14, color: Color(0xCCFFFFFF))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showUpdateBankSheet(context),
            child: Container(
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: const Text('Update Bank Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF364153))),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Transactions Card ─────────────────────────────────────────────────────

  Widget _buildTransactionsCard(BuildContext context, WalletSummary summary) {
    final all = summary.transactions;
    final visible = _showAll ? all : all.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 10)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Transactions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF101828))),
              if (all.isNotEmpty)
                Text('${all.length} payment${all.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6A7282))),
            ],
          ),
          const SizedBox(height: 16),

          if (all.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('No payments yet',
                      style: TextStyle(fontSize: 15, color: Color(0xFF6A7282))),
                  const SizedBox(height: 4),
                  const Text('Payments from clients will appear here',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                ],
              ),
            )
          else ...[
            ...visible.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildTransactionRow(t),
            )),
            if (all.length > 5)
              GestureDetector(
                onTap: () => setState(() => _showAll = !_showAll),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _showAll ? 'Show Less' : 'View All ${all.length} Transactions',
                    style: const TextStyle(fontSize: 15, color: Color(0xFF364153)),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionRow(WalletTransaction t) {
    final isCompleted = t.status == 'completed';
    final typeLabel =
        '${t.sessionType == 'video' ? 'Video' : 'Audio'} · ${t.planType == 'package' ? 'Package' : 'Single'}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.arrow_downward_rounded, size: 20, color: Color(0xFF00A63E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.clientName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF101828)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(t.date)} · $typeLabel',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6A7282)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${_formatCurrency(t.amount)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF00A63E)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFFDCFCE7) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Confirmed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFF54900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Bottom Sheets ─────────────────────────────────────────────────────────

  void _showWithdrawSheet(BuildContext context, WalletSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WithdrawSheet(availableBalance: _formatCurrency(summary.availableBalance)),
    );
  }

  void _showUpdateBankSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _UpdateBankSheet(),
    );
  }
}

// ─── Withdraw Bottom Sheet ──────────────────────────────────────────────────

class _WithdrawSheet extends StatefulWidget {
  final String availableBalance;
  const _WithdrawSheet({required this.availableBalance});
  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Withdraw to Bank',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
            const SizedBox(height: 4),
            Text('Available balance: ${widget.availableBalance}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6A7282))),
            const SizedBox(height: 20),
            const Text('Amount',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF101828))),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance_outlined, size: 18, color: AppColors.primary),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bank of America',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF101828))),
                      Text('\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 4532',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6A7282))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Withdrawal request submitted'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C950),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Confirm Withdrawal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Update Bank Sheet ──────────────────────────────────────────────────────

class _UpdateBankSheet extends StatefulWidget {
  const _UpdateBankSheet();
  @override
  State<_UpdateBankSheet> createState() => _UpdateBankSheetState();
}

class _UpdateBankSheetState extends State<_UpdateBankSheet> {
  final _bankCtrl = TextEditingController(text: 'Bank of America');
  final _accountCtrl = TextEditingController(text: '4532');
  final _holderCtrl = TextEditingController(text: 'Account Holder');

  @override
  void dispose() { _bankCtrl.dispose(); _accountCtrl.dispose(); _holderCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 20),
            const Text('Update Bank Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF101828))),
            const SizedBox(height: 20),
            _field('Bank Name', _bankCtrl, 'e.g. Bank of America'),
            const SizedBox(height: 14),
            _field('Account Holder', _holderCtrl, 'Full name'),
            const SizedBox(height: 14),
            _field('Account Number (last 4)', _accountCtrl, '4 digits',
                keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Bank details updated'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Bank Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF101828))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ],
    );
  }
}