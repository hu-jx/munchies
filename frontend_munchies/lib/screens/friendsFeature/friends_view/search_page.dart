import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view_model/search_view_model.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  final vm = SearchViewModel();
  List<UserProfile> foundUsers = [];

  void onSearch() async {
    final query = searchController.text;
    await vm.findUsers(query);

    setState(() {
      foundUsers = vm.usersFound;
      if (searchController.text != "") {
        isSearching = true;
      } else {
        isSearching = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearch);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.lightBeige,
      appBar: AppBar(
        title: Text("Search for friends", style: inputTextStyle),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
        backgroundColor: Colours.greyPink.withValues(alpha: 0.35),
      ),
      body: Column(
        children: [
          //search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colours.grey),
                ),
                hintText: "Search using email address...",
                hintStyle: TextStyle(fontFamily: "Poppins", color: Colors.grey),
              ),
            ),
          ),
          //search results below
          //for testing api results
          //Text(foundUsers.map((u) => u.emailAddress).join(", ")),
          searchResults(),
        ],
      ),
    );
  }

  Widget searchResults() {
    if (isSearching == false) {
      return Center(child: Text(""));
    } else if (foundUsers.isEmpty) {
      return Center(child: Text("No user found", style: TextStyle(fontFamily: "Poppins", fontSize: 20, color: Colours.greyPink),));
    }
    return Expanded(
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: foundUsers.length,
        itemBuilder: (BuildContext context, int index) {
          final user = foundUsers[index];
          final userEmail = user.emailAddress;
          return Container(
            height: 50,
            child: Center(child: Text('User: $userEmail', style: TextStyle(fontFamily: "Poppins", fontSize: 16),)),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
