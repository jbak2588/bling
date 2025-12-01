// lib/features/together/screens/ticket_scan_screen.dart

import 'dart:convert';
import 'package:bling_app/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_localization/easy_localization.dart';

class TicketScanScreen extends StatefulWidget {
  final String eventId; // 현재 모임 ID (이 모임의 티켓인지 확인용)

  const TicketScanScreen({super.key, required this.eventId});

  @override
  State<TicketScanScreen> createState() => _TicketScanScreenState();
}

class _TicketScanScreenState extends State<TicketScanScreen> {
  bool _isScanned = false; // 중복 스캔 방지 플래그

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('together.ticketScan.title'.tr())),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return;
          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              _processQrCode(barcode.rawValue!);
              break; // 하나만 인식하면 됨
            }
          }
        },
      ),
    );
  }

  Future<void> _processQrCode(String rawData) async {
    setState(() => _isScanned = true);

    try {
      // 1. JSON 파싱 (작업 30에서 정의한 포맷: {uid, pid, token})
      final Map<String, dynamic> data = jsonDecode(rawData);
      final String uid = data['uid'];
      final String pid = data['pid'];

      // 2. 기본 검증 (현재 모임의 티켓이 맞는지)
      if (pid != widget.eventId) {
        _showResultDialog(
            isSuccess: false,
            title: 'together.ticketScan.invalidTitle'.tr(),
            message: 'together.ticketScan.invalidMessage'.tr());
        return;
      }

      // 3. 사용자 정보 가져오기 (상호 인식을 위해 닉네임 표시)
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final user = UserModel.fromFirestore(userDoc);

      // 4. 티켓 '사용됨' 처리 (선택 사항 - 출석 체크용)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('my_tickets')
          .doc(pid)
          .update({'isUsed': true});

      // 5. 성공 팝업
      if (!mounted) return;
      _showResultDialog(
        isSuccess: true,
        title: 'together.ticketScan.successTitle'.tr(),
        message: 'together.ticketScan.successMessage'
            .tr(namedArgs: {'nickname': user.nickname}),
      );
    } catch (e) {
      _showResultDialog(
        isSuccess: false,
        title: 'together.ticketScan.errorTitle'.tr(),
        message: 'together.ticketScan.errorMessage'
            .tr(namedArgs: {'error': e.toString()}),
      );
    }
  }

  void _showResultDialog(
      {required bool isSuccess,
      required String title,
      required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // 다이얼로그 닫기
              if (isSuccess) {
                Navigator.pop(context); // 스캔 화면 닫기 (성공 시)
              } else {
                setState(() => _isScanned = false); // 실패 시 다시 스캔 가능하게 리셋
              }
            },
            child: Text('common.confirm'.tr()),
          ),
        ],
      ),
    );
  }
}
