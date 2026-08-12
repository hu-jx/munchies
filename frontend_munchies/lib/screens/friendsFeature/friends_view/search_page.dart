import 'package:flutter/material.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view/searched_profile.dart';
import 'package:frontend_munchies/screens/friendsFeature/friends_view_model/search_view_model.dart';
import 'package:frontend_munchies/styles/colours.dart';
import 'package:frontend_munchies/styles/textStyles.dart';

class SearchPage extends StatefulWidget {
  final SearchViewModel vm;
  final Future<UserProfile> Function()? getCurrentUPTest;
  final Future<String> Function(String, String)? checkStatusTest;

  const SearchPage({
    super.key,
    required this.vm,
    this.getCurrentUPTest,
    this.checkStatusTest,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isLoading = false;

  UserProfile? foundUser;

  void onSearch() async {
    final query = searchController.text;
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        foundUser = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      isSearching = true;
    });

    await widget.vm.findUsers(query);

    setState(() {
      foundUser = widget.vm.foundUser;
      isSearching = true;
      isLoading = false;
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
        surfaceTintColor: Colors.transparent,
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
              style: normalTextStyle,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colours.grey),
                ),
                hintText: "Search using email address...",
                hintStyle: TextStyle(fontFamily: "Poppins", color: Colors.grey),
              ),
            ),
          ),
          searchResults(),
        ],
      ),
    );
  }

  Widget searchResults() {
    if (isSearching == false) {
      return Center(child: Text(""));
    }
    if (isLoading) {
      return CircularProgressIndicator(color: Colours.greyPink);
    }
    final user = foundUser;
    if (user == null) {
      return Center(
        child: Text(
          "No user found",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 20,
            color: Colours.greyPink,
          ),
        ),
      );
    }
    return SearchedProfile(
      key: ValueKey(user.mongo_id),
      userProfile: user,
      getCurrentUPTest: widget.getCurrentUPTest,
      checkStatusTest: widget.checkStatusTest,
    );
  }
}
