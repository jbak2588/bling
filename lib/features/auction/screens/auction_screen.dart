import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';

class AuctionScreen extends StatelessWidget {
  final UserModel? userModel;
  const AuctionScreen({this.userModel, super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Auction Screen'));
}
