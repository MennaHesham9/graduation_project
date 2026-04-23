// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
//
// class CoachWalletScreen extends StatefulWidget {
//   const CoachWalletScreen({super.key});
//
//   @override
//   State<CoachWalletScreen> createState() => _CoachWalletScreenState();
// }
//
// class _CoachWalletScreenState extends State<CoachWalletScreen> {
//   int _selectedTransactionTab = 0; // 0 = All, 1 = Income, 2 = Withdrawn
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildHeader(context),
//         Expanded(
//           child: _buildBody(context),
//         ),
//       ],
//     );
//   }
//
//   // ─── Header ────────────────────────────────────────────────────────────────
//
//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 10),
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.only(
//         top: 48,
//         left: 24,
//         right: 24,
//         bottom: 16,
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.maybePop(context),
//             child: Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF3F4F6),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 size: 16,
//                 color: Color(0xFF101828),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           const Expanded(
//             child: Text(
//               'My Wallet',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF101828),
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () => _showComingSoon(context, 'Wallet history'),
//             child: Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF3F4F6),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: const Icon(
//                 Icons.history_rounded,
//                 size: 18,
//                 color: Color(0xFF101828),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Body ───────────────────────────────────────────────────────────────────
//
//   Widget _buildBody(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFFFAF5FF),
//             Color(0xFFEFF6FF),
//             Color(0xFFFDF2F8),
//           ],
//           stops: [0.0, 0.5, 1.0],
//         ),
//       ),
//       child: ListView(
//         padding: const EdgeInsets.all(24),
//         children: [
//           _buildBalanceCard(context),
//           const SizedBox(height: 20),
//           _buildQuickActions(context),
//           const SizedBox(height: 20),
//           _buildEarningsSummary(),
//           const SizedBox(height: 20),
//           _buildTransactionsSection(),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }
//
//   // ─── Balance Card ──────────────────────────────────────────────────────────
//
//   Widget _buildBalanceCard(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF2F8F9D),
//             Color(0xFF1A6E7A),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.35),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Available Balance',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white70,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//               Container(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.circle, size: 8, color: Color(0xFF4ADE80)),
//                     SizedBox(width: 4),
//                     Text(
//                       'Active',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             '\$2,450.00',
//             style: TextStyle(
//               fontSize: 36,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//               letterSpacing: -0.5,
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             '≈ 24 sessions this month',
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.white60,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Container(
//             height: 1,
//             color: Colors.white.withOpacity(0.2),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildBalanceStat(
//                   label: 'Total Earned',
//                   value: '\$12,800',
//                   icon: Icons.trending_up_rounded,
//                 ),
//               ),
//               Container(
//                 width: 1,
//                 height: 40,
//                 color: Colors.white.withOpacity(0.2),
//               ),
//               Expanded(
//                 child: _buildBalanceStat(
//                   label: 'Withdrawn',
//                   value: '\$10,350',
//                   icon: Icons.account_balance_outlined,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBalanceStat({
//     required String label,
//     required String value,
//     required IconData icon,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, size: 16, color: Colors.white),
//           ),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.white,
//                 ),
//               ),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 11,
//                   color: Colors.white60,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ─── Quick Actions ─────────────────────────────────────────────────────────
//
//   Widget _buildQuickActions(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildActionButton(
//             icon: Icons.account_balance_wallet_outlined,
//             label: 'Withdraw',
//             onTap: () => _showWithdrawSheet(context),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildActionButton(
//             icon: Icons.credit_card_outlined,
//             label: 'Add Bank',
//             onTap: () => _showAddBankSheet(context),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _buildActionButton(
//             icon: Icons.receipt_long_outlined,
//             label: 'Statement',
//             onTap: () => _showComingSoon(context, 'Statement'),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.8),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 15,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Icon(icon, size: 22, color: AppColors.primary),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF101828),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ─── Earnings Summary ──────────────────────────────────────────────────────
//
//   Widget _buildEarningsSummary() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(left: 8),
//           child: Text(
//             'Earnings Overview',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF101828),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 15,
//                 offset: const Offset(0, 10),
//               ),
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 6,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'This Month',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF4A5565),
//                     ),
//                   ),
//                   Container(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFDCFCE7),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.arrow_upward_rounded,
//                             size: 12, color: Color(0xFF16A34A)),
//                         SizedBox(width: 2),
//                         Text(
//                           '+12.5%',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF16A34A),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildEarningsStat(
//                       label: 'Sessions',
//                       value: '24',
//                       sub: 'this month',
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   Expanded(
//                     child: _buildEarningsStat(
//                       label: 'Earned',
//                       value: '\$2,450',
//                       sub: 'this month',
//                       color: const Color(0xFF7C3AED),
//                     ),
//                   ),
//                   Expanded(
//                     child: _buildEarningsStat(
//                       label: 'Avg/Session',
//                       value: '\$102',
//                       sub: 'per session',
//                       color: const Color(0xFFDB2777),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               _buildEarningsBar(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEarningsStat({
//     required String label,
//     required String value,
//     required String sub,
//     required Color color,
//   }) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF101828),
//           ),
//         ),
//         Text(
//           sub,
//           style: const TextStyle(
//             fontSize: 11,
//             color: Color(0xFF6A7282),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEarningsBar() {
//     // Simple visual bar showing weekly breakdown
//     final List<_WeekBar> weeks = [
//       _WeekBar('W1', 0.6),
//       _WeekBar('W2', 0.8),
//       _WeekBar('W3', 0.5),
//       _WeekBar('W4', 1.0),
//     ];
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Weekly breakdown',
//           style: TextStyle(
//             fontSize: 12,
//             color: Color(0xFF6A7282),
//           ),
//         ),
//         const SizedBox(height: 10),
//         SizedBox(
//           height: 60,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: weeks
//                 .map(
//                   (w) => Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 400),
//                         height: 44 * w.ratio,
//                         decoration: BoxDecoration(
//                           color: w.ratio == 1.0
//                               ? AppColors.primary
//                               : AppColors.primary.withOpacity(0.25),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         w.label,
//                         style: const TextStyle(
//                           fontSize: 11,
//                           color: Color(0xFF6A7282),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             )
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ─── Transactions ──────────────────────────────────────────────────────────
//
//   Widget _buildTransactionsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(left: 8),
//           child: Text(
//             'Transactions',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF101828),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         _buildTransactionTabs(),
//         const SizedBox(height: 12),
//         _buildTransactionList(),
//       ],
//     );
//   }
//
//   Widget _buildTransactionTabs() {
//     const tabs = ['All', 'Income', 'Withdrawn'];
//     return Container(
//       padding: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF3F4F6),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: List.generate(tabs.length, (i) {
//           final selected = _selectedTransactionTab == i;
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => setState(() => _selectedTransactionTab = i),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: selected ? Colors.white : Colors.transparent,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: selected
//                       ? [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2),
//                     ),
//                   ]
//                       : null,
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   tabs[i],
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: selected
//                         ? AppColors.primary
//                         : const Color(0xFF4A5565),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
//
//   Widget _buildTransactionList() {
//     final allTransactions = _transactions;
//     final filtered = _selectedTransactionTab == 0
//         ? allTransactions
//         : _selectedTransactionTab == 1
//         ? allTransactions
//         .where((t) => t.type == _TransactionType.income)
//         .toList()
//         : allTransactions
//         .where((t) => t.type == _TransactionType.withdrawal)
//         .toList();
//
//     if (filtered.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.symmetric(vertical: 32),
//         alignment: Alignment.center,
//         child: const Text(
//           'No transactions found',
//           style: TextStyle(fontSize: 14, color: Color(0xFF6A7282)),
//         ),
//       );
//     }
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.8),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 10),
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 6,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.hardEdge,
//       child: Column(
//         children: List.generate(filtered.length, (i) {
//           return _buildTransactionRow(
//             transaction: filtered[i],
//             hasDivider: i < filtered.length - 1,
//           );
//         }),
//       ),
//     );
//   }
//
//   Widget _buildTransactionRow({
//     required _Transaction transaction,
//     required bool hasDivider,
//   }) {
//     final isIncome = transaction.type == _TransactionType.income;
//     return Container(
//       decoration: hasDivider
//           ? const BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
//         ),
//       )
//           : null,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       child: Row(
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: isIncome
//                   ? const Color(0xFFDCFCE7)
//                   : const Color(0xFFFEF2F2),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(
//               isIncome
//                   ? Icons.arrow_downward_rounded
//                   : Icons.arrow_upward_rounded,
//               size: 20,
//               color: isIncome
//                   ? const Color(0xFF16A34A)
//                   : const Color(0xFFE7000B),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   transaction.title,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                     color: Color(0xFF101828),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   transaction.subtitle,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF6A7282),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '${isIncome ? '+' : '-'}\$${transaction.amount}',
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: isIncome
//                       ? const Color(0xFF16A34A)
//                       : const Color(0xFFE7000B),
//                 ),
//               ),
//               const SizedBox(height: 2),
//               _buildTransactionStatusBadge(transaction.status),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTransactionStatusBadge(_TransactionStatus status) {
//     final Color bg;
//     final Color textColor;
//     final String label;
//
//     switch (status) {
//       case _TransactionStatus.completed:
//         bg = const Color(0xFFDCFCE7);
//         textColor = const Color(0xFF16A34A);
//         label = 'Completed';
//         break;
//       case _TransactionStatus.pending:
//         bg = const Color(0xFFFFF7ED);
//         textColor = const Color(0xFFF54900);
//         label = 'Pending';
//         break;
//       case _TransactionStatus.processing:
//         bg = const Color(0xFFEFF6FF);
//         textColor = const Color(0xFF2563EB);
//         label = 'Processing';
//         break;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 11,
//           fontWeight: FontWeight.w500,
//           color: textColor,
//         ),
//       ),
//     );
//   }
//
//   // ─── Dummy Data ────────────────────────────────────────────────────────────
//
//   final List<_Transaction> _transactions = const [
//     _Transaction(
//       title: 'Session with Sarah M.',
//       subtitle: 'Dec 5 · Individual therapy',
//       amount: '120',
//       type: _TransactionType.income,
//       status: _TransactionStatus.completed,
//     ),
//     _Transaction(
//       title: 'Session with James K.',
//       subtitle: 'Dec 4 · Couples counseling',
//       amount: '180',
//       type: _TransactionType.income,
//       status: _TransactionStatus.completed,
//     ),
//     _Transaction(
//       title: 'Bank Withdrawal',
//       subtitle: 'Dec 3 · To ••••4821',
//       amount: '500',
//       type: _TransactionType.withdrawal,
//       status: _TransactionStatus.completed,
//     ),
//     _Transaction(
//       title: 'Session with Mia T.',
//       subtitle: 'Dec 2 · Anxiety management',
//       amount: '100',
//       type: _TransactionType.income,
//       status: _TransactionStatus.completed,
//     ),
//     _Transaction(
//       title: 'Session with Omar R.',
//       subtitle: 'Dec 1 · Stress coaching',
//       amount: '120',
//       type: _TransactionType.income,
//       status: _TransactionStatus.pending,
//     ),
//     _Transaction(
//       title: 'Bank Withdrawal',
//       subtitle: 'Nov 28 · To ••••4821',
//       amount: '800',
//       type: _TransactionType.withdrawal,
//       status: _TransactionStatus.processing,
//     ),
//   ];
//
//   // ─── Bottom Sheets ─────────────────────────────────────────────────────────
//
//   void _showWithdrawSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _WithdrawSheet(availableBalance: '2,450.00'),
//     );
//   }
//
//   void _showAddBankSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const _AddBankSheet(),
//     );
//   }
//
//   void _showComingSoon(BuildContext context, String feature) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$feature coming soon'),
//         backgroundColor: AppColors.primary,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }
//
// // ─── Withdraw Bottom Sheet ──────────────────────────────────────────────────
//
// class _WithdrawSheet extends StatefulWidget {
//   final String availableBalance;
//   const _WithdrawSheet({required this.availableBalance});
//
//   @override
//   State<_WithdrawSheet> createState() => _WithdrawSheetState();
// }
//
// class _WithdrawSheetState extends State<_WithdrawSheet> {
//   final _amountController = TextEditingController();
//   int _selectedBank = 0;
//
//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE5E7EB),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Withdraw Funds',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF101828),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               'Available: \$${widget.availableBalance}',
//               style: const TextStyle(fontSize: 13, color: Color(0xFF6A7282)),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Amount',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF101828),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _amountController,
//               keyboardType: TextInputType.number,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF101828),
//               ),
//               decoration: InputDecoration(
//                 prefixText: '\$ ',
//                 hintText: '0.00',
//                 hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
//                 filled: true,
//                 fillColor: const Color(0xFFF9FAFB),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide:
//                   const BorderSide(color: AppColors.primary, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16, vertical: 14),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'To Bank Account',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF101828),
//               ),
//             ),
//             const SizedBox(height: 8),
//             _BankOption(
//               bankName: 'National Bank',
//               accountNumber: '••••4821',
//               isSelected: _selectedBank == 0,
//               onTap: () => setState(() => _selectedBank = 0),
//             ),
//             const SizedBox(height: 8),
//             _BankOption(
//               bankName: 'CIB Bank',
//               accountNumber: '••••9203',
//               isSelected: _selectedBank == 1,
//               onTap: () => setState(() => _selectedBank = 1),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: const Text('Withdrawal request submitted'),
//                       backgroundColor: AppColors.primary,
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 child: const Text(
//                   'Confirm Withdrawal',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _BankOption extends StatelessWidget {
//   final String bankName;
//   final String accountNumber;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _BankOption({
//     required this.bankName,
//     required this.accountNumber,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.primary.withOpacity(0.06)
//               : const Color(0xFFF9FAFB),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
//             width: isSelected ? 1.5 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(Icons.account_balance_outlined,
//                   size: 18, color: AppColors.primary),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     bankName,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF101828),
//                     ),
//                   ),
//                   Text(
//                     accountNumber,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF6A7282),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (isSelected)
//               const Icon(Icons.check_circle_rounded,
//                   size: 20, color: AppColors.primary),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Add Bank Bottom Sheet ──────────────────────────────────────────────────
//
// class _AddBankSheet extends StatefulWidget {
//   const _AddBankSheet();
//
//   @override
//   State<_AddBankSheet> createState() => _AddBankSheetState();
// }
//
// class _AddBankSheetState extends State<_AddBankSheet> {
//   final _bankNameController = TextEditingController();
//   final _accountNumberController = TextEditingController();
//   final _accountHolderController = TextEditingController();
//
//   @override
//   void dispose() {
//     _bankNameController.dispose();
//     _accountNumberController.dispose();
//     _accountHolderController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE5E7EB),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Add Bank Account',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF101828),
//               ),
//             ),
//             const SizedBox(height: 20),
//             _buildSheetField(
//                 controller: _bankNameController,
//                 label: 'Bank Name',
//                 hint: 'e.g. National Bank'),
//             const SizedBox(height: 14),
//             _buildSheetField(
//                 controller: _accountHolderController,
//                 label: 'Account Holder Name',
//                 hint: 'Full name as on account'),
//             const SizedBox(height: 14),
//             _buildSheetField(
//                 controller: _accountNumberController,
//                 label: 'Account Number',
//                 hint: 'Enter account number',
//                 keyboardType: TextInputType.number),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: const Text('Bank account added successfully'),
//                       backgroundColor: AppColors.primary,
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 child: const Text(
//                   'Save Bank Account',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSheetField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF101828),
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextField(
//           controller: controller,
//           keyboardType: keyboardType,
//           style: const TextStyle(
//             fontSize: 15,
//             color: Color(0xFF101828),
//           ),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
//             filled: true,
//             fillColor: const Color(0xFFF9FAFB),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(14),
//               borderSide:
//               const BorderSide(color: AppColors.primary, width: 1.5),
//             ),
//             contentPadding:
//             const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─── Data Models ───────────────────────────────────────────────────────────
//
// enum _TransactionType { income, withdrawal }
//
// enum _TransactionStatus { completed, pending, processing }
//
// class _Transaction {
//   final String title;
//   final String subtitle;
//   final String amount;
//   final _TransactionType type;
//   final _TransactionStatus status;
//
//   const _Transaction({
//     required this.title,
//     required this.subtitle,
//     required this.amount,
//     required this.type,
//     required this.status,
//   });
// }
//
// class _WeekBar {
//   final String label;
//   final double ratio;
//   const _WeekBar(this.label, this.ratio);
// }

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CoachWalletScreen extends StatelessWidget {
  const CoachWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildScrollableBody(context),
          ),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        top: 48,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFF101828),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Wallet & Payments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF101828),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Scrollable Body ────────────────────────────────────────────────────────

  Widget _buildScrollableBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.95, -1.0),
          end: Alignment(0.95, 1.0),
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFEFF6FF),
            Color(0xFFFDF2F8),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          _buildBalanceCard(context),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 20),
          _buildBankAccountCard(context),
          const SizedBox(height: 20),
          _buildRecentTransactionsCard(context),
        ],
      ),
    );
  }

  // ─── Balance Card (green gradient) ─────────────────────────────────────────

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.87, -1.0),
          end: Alignment(0.87, 1.0),
          colors: [
            Color(0xFF00C950),
            Color(0xFF00BC7D),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 50,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xE6FFFFFF),
                  fontWeight: FontWeight.w400,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.more_horiz_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '\$1,245.00',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showWithdrawSheet(context),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Withdraw to Bank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats Row (This Month / Total Earned) ──────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'This Month',
            value: '\$3,245',
            labelColor: const Color(0xFF00A63E),
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: 'Total Earned',
            value: '\$18,750',
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
    required Color labelColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: labelColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: Color(0xFF101828),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bank Account Card ──────────────────────────────────────────────────────

  Widget _buildBankAccountCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bank Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF101828),
                ),
              ),
              GestureDetector(
                onTap: () => _showUpdateBankSheet(context),
                child: const Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bank card — teal gradient matching Figma
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.75, -1.0),
                end: Alignment(0.75, 1.0),
                colors: [
                  Color(0xFF2F8F9D),
                  Color(0xFF20A8BC),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank of America',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 4532',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Michael Chen',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Update Bank Details button
          GestureDetector(
            onTap: () => _showUpdateBankSheet(context),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Update Bank Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF364153),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent Transactions Card ───────────────────────────────────────────────

  Widget _buildRecentTransactionsCard(BuildContext context) {
    const transactions = [
      _Transaction(
        name: 'Sarah Johnson',
        date: 'Dec 3, 2025',
        amount: '+\$75',
        amountColor: Color(0xFF00A63E),
        status: 'completed',
        iconBg: Color(0xFFDCFCE7),
        isIncome: true,
      ),
      _Transaction(
        name: 'James Miller',
        date: 'Dec 2, 2025',
        amount: '+\$75',
        amountColor: Color(0xFF00A63E),
        status: 'completed',
        iconBg: Color(0xFFDCFCE7),
        isIncome: true,
      ),
      _Transaction(
        name: 'Bank Transfer',
        date: 'Dec 1, 2025',
        amount: '-\$500',
        amountColor: Color(0xFFF54900),
        status: 'completed',
        iconBg: Color(0xFFFFEDD4),
        isIncome: false,
      ),
      _Transaction(
        name: 'Emma Davis',
        date: 'Nov 30, 2025',
        amount: '+\$85',
        amountColor: Color(0xFF00A63E),
        status: 'completed',
        iconBg: Color(0xFFDCFCE7),
        isIncome: true,
      ),
      _Transaction(
        name: 'Michael Brown',
        date: 'Nov 29, 2025',
        amount: '+\$75',
        amountColor: Color(0xFF00A63E),
        status: 'completed',
        iconBg: Color(0xFFDCFCE7),
        isIncome: true,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          // Transaction rows with 12px gap between them
          ...transactions.map(
                (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionRow(t),
            ),
          ),
          // View All Transactions button
          GestureDetector(
            onTap: () => _showAllTransactions(context),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text(
                'View All Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF364153),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(_Transaction t) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Icon bubble
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              t.isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 18,
              color: t.isIncome
                  ? const Color(0xFF00A63E)
                  : const Color(0xFFF54900),
            ),
          ),
          const SizedBox(width: 12),
          // Name + Date
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6A7282),
                  ),
                ),
              ],
            ),
          ),
          // Amount + Status
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                t.amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: t.amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.status,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6A7282),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  void _showWithdrawSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _WithdrawSheet(),
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

  void _showAllTransactions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All transactions coming soon'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Withdraw Bottom Sheet ──────────────────────────────────────────────────

class _WithdrawSheet extends StatefulWidget {
  const _WithdrawSheet();

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Withdraw to Bank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Available balance: \$1,245.00',
              style: TextStyle(fontSize: 13, color: Color(0xFF6A7282)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF101828),
              ),
            ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_balance_outlined,
                      size: 18, color: AppColors.primary),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bank of America',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF101828),
                        ),
                      ),
                      Text(
                        '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 4532',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF6A7282)),
                      ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Withdrawal request submitted'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C950),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Confirm Withdrawal',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
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
  final _bankController =
  TextEditingController(text: 'Bank of America');
  final _accountController =
  TextEditingController(text: '\u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 \u2022\u2022\u2022\u2022 4532');
  final _holderController =
  TextEditingController(text: 'Michael Chen');

  @override
  void dispose() {
    _bankController.dispose();
    _accountController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Update Bank Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 20),
            _buildField(
                'Bank Name', _bankController, 'e.g. Bank of America'),
            const SizedBox(height: 14),
            _buildField(
                'Account Holder', _holderController, 'Full name'),
            const SizedBox(height: 14),
            _buildField(
              'Account Number',
              _accountController,
              'Account number',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Bank details updated'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Save Bank Details',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      String label,
      TextEditingController controller,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 13),
          ),
        ),
      ],
    );
  }
}

// ─── Data Model ─────────────────────────────────────────────────────────────

class _Transaction {
  final String name;
  final String date;
  final String amount;
  final Color amountColor;
  final String status;
  final Color iconBg;
  final bool isIncome;

  const _Transaction({
    required this.name,
    required this.date,
    required this.amount,
    required this.amountColor,
    required this.status,
    required this.iconBg,
    required this.isIncome,
  });
}