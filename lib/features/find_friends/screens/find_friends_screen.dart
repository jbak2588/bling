// lib/features/find_friends/screens/find_friends_screen.dart

import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/features/find_friends/data/find_friend_repository.dart';
import 'package:bling_app/features/find_friends/screens/find_friend_detail_screen.dart';
import 'package:bling_app/features/find_friends/widgets/findfriend_card.dart';
import 'package:bling_app/features/location/screens/location_filter_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'findfriend_form_screen.dart';

class FindFriendsScreen extends StatefulWidget {
  final UserModel? userModel;
  const FindFriendsScreen({this.userModel, super.key});

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  Map<String, String?>? _locationFilter;

  Future<void> _openLocationFilter() async {
    final raw = await Navigator.push<Map<String, String?>>(
      context,
      MaterialPageRoute(
          builder: (_) => LocationFilterScreen(userModel: widget.userModel)),
    );
    if (raw != null) {
      setState(() {
        _locationFilter = {
          'prov': raw['prov'],
          'kab': raw['kab'] ?? raw['kota'],
          'kec': raw['kec'],
          'kel': raw['kel'],
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = widget.userModel;
    if (userModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userModel.isDatingProfile != true) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              Text(
                "findFriend.prompt_title".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            FindFriendFormScreen(userModel: userModel)),
                  );
                },
                child: Text("findFriend.prompt_button".tr()),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<List<UserModel>>(
        stream: FindFriendRepository()
            .getUsersForFindFriends(userModel, locationFilter: _locationFilter),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("findFriend.noFriendsFound".tr()));
          }

          final userList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FindFriendDetailScreen(
                          user: user, currentUserModel: userModel),
                    ),
                  );
                },
                child: FindFriendCard(user: user),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'find_friends_filter',
            onPressed: _openLocationFilter,
            tooltip: 'locationFilter.title'.tr(),
            child: const Icon(Icons.filter_list),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'find_friends_edit_profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FindFriendFormScreen(userModel: userModel)),
              );
            },
            tooltip: "findFriend.editProfileTitle".tr(),
            child: const Icon(Icons.edit_note_outlined),
          ),
        ],
      ),
    );
  }
}
