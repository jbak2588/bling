// lib/features/together/widgets/user_ticket_list.dart

import 'package:bling_app/features/together/data/together_repository.dart';
import 'package:bling_app/features/together/models/together_ticket_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class UserTicketList extends StatelessWidget {
  final String userId;

  const UserTicketList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TogetherTicketModel>>(
      stream: TogetherRepository().fetchMyTickets(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final tickets = snapshot.data ?? [];

        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.confirmation_number_outlined,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text("아직 참여한 모임이 없어요.", // TODO: together.noTickets 키 추가 권장
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildTicketCard(context, tickets[index]);
          },
        );
      },
    );
  }

  Widget _buildTicketCard(BuildContext context, TogetherTicketModel ticket) {
    final dateStr = DateFormat('MM/dd HH:mm').format(ticket.meetTime.toDate());
    // 테마별 색상 (간소화)
    final isNeon = ticket.designTheme == 'neon';
    final bgColor = isNeon ? const Color(0xFFCCFF00) : Colors.white;
    final borderColor = isNeon ? Colors.black : Colors.grey[300]!;

    return GestureDetector(
      onTap: () => _showQrDialog(context, ticket),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(2, 2),
              blurRadius: 4,
            )
          ],
        ),
        child: Row(
          children: [
            // 왼쪽: 티켓 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOGETHER PASS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 4),
                        Text(dateStr, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ticket.location,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 오른쪽: QR 썸네일 & 절취선
            Container(
              width: 1,
              height: 100,
              color: borderColor, // 절취선 효과 (실선)
            ),
            Container(
              width: 80,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: ticket.qrCodeString,
                    size: 50,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  const Text("TAP",
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQrDialog(BuildContext context, TogetherTicketModel ticket) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ticket.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              QrImageView(
                data: ticket.qrCodeString,
                size: 200,
              ),
              const SizedBox(height: 24),
              const Text("주최자에게 이 QR 코드를 보여주세요.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("닫기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
