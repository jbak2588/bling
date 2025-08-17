// lib/features/local_stores/screens/local_stores_screen.dart

import 'package:bling_app/core/models/shop_model.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/local_stores/data/shop_repository.dart';
import 'package:bling_app/features/local_stores/widgets/shop_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'create_shop_screen.dart'; // [추가]

class LocalStoresScreen extends StatelessWidget {
  final UserModel? userModel;
  final Map<String, String?>? locationFilter;
  const LocalStoresScreen({this.userModel, this.locationFilter, super.key});

  List<ShopModel> _applyLocationFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    final filter = locationFilter;
    if (filter == null) {
      return allDocs.map((doc) => ShopModel.fromFirestore(doc)).toList();
    }

    String? key;
    if (filter['kel'] != null) {
      key = 'kel';
    } else if (filter['kec'] != null) {
      key = 'kec';
    } else if (filter['kab'] != null) {
      key = 'kab';
    } else if (filter['kota'] != null) {
      key = 'kota';
    } else if (filter['prov'] != null) {
      key = 'prov';
    }
    if (key == null) {
      return allDocs.map((doc) => ShopModel.fromFirestore(doc)).toList();
    }

    final value = filter[key]!.toLowerCase();
    return allDocs
        .where((doc) =>
            (doc.data()['locationParts']?[key] ?? '')
                .toString()
                .toLowerCase() ==
            value)
        .map((doc) => ShopModel.fromFirestore(doc))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final ShopRepository shopRepository = ShopRepository();
    final userProvince = userModel?.locationParts?['prov'];

    if (userModel?.locationParts?['prov'] == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('localStores.setLocationPrompt'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: shopRepository.fetchShops(userProvince),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('localStores.error'
                    .tr(namedArgs: {'error': snapshot.error.toString()})));
          }

          final allDocs = snapshot.data?.docs ?? [];
          final shops = _applyLocationFilter(allDocs);

          if (shops.isEmpty) {
            return Center(child: Text('localStores.empty'.tr()));
          }

          return ListView.builder(
            itemCount: shops.length,
            itemBuilder: (context, index) {
              return ShopCard(shop: shops[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // V V V --- [수정] 상점 등록 화면으로 이동하는 로직 --- V V V
          if (userModel != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CreateShopScreen(userModel: userModel!),
            ));
          } else {
            // 로그인하지 않은 사용자에 대한 처리
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('main.errors.loginRequired'.tr())));
          }
         
        },
        tooltip: 'localStores.create.tooltip'.tr(),
        child: const Icon(Icons.add_business_outlined),
      ),
    );
  }
}
