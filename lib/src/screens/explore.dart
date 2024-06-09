import 'package:flutter/material.dart';
import 'package:guardiancare/src/constants/colors.dart';

class Explore extends StatelessWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Explore"),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Row for Search and Filters
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Row(
            //     children: [
            //       const Expanded(
            //         child: TextField(
            //           decoration: InputDecoration(
            //               hintText: "Search...",
            //               prefixIcon: Icon(
            //                 Icons.search,
            //                 color: tPrimaryColor,
            //               ),
            //               focusedBorder: UnderlineInputBorder(
            //                   borderSide: BorderSide(color: tPrimaryColor))),
            //         ),
            //       ),
            //       const SizedBox(width: 16.0),
            //       ElevatedButton(
            //         onPressed: () {
            //           // Implement filter action
            //         },
            //         child: const Text("Filter",
            //             style: TextStyle(color: tPrimaryColor)),
            //       ),
            //     ],
            //   ),
            // ),
            // Tabs Section
            DefaultTabController(
              length: 1,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Recommended'),
                      // Tab(text: 'Action'),
                      // Tab(text: 'Campaigns'),
                      // Tab(text: 'Content'),
                    ],
                    indicatorColor: tPrimaryColor,
                    labelColor: tPrimaryColor,
                  ),
                  // TabBarView for displaying content based on selected tab
                  SizedBox(
                    height:
                        400, // Adjust the height according to your requirement
                    child: TabBarView(
                      children: [
                        // Content for Feature tab
                        _buildContentCard(
                          imageUrl: 'assets/images/image.png',
                          title: 'Feature Title',
                          description: 'Feature Description',
                        ),
                        // Content for Action tab
                        // _buildContentCard(
                        //   imageUrl: 'assets/images/image.png',
                        //   title: 'Action Title',
                        //   description: 'Action Description',
                        // ),
                        // Content for Campaigns tab
                        // _buildContentCard(
                        //   imageUrl: 'assets/images/image.png',
                        //   title: 'Campaigns Title',
                        //   description: 'Campaigns Description',
                        // ),
                        // Content for Content tab
                        // _buildContentCard(
                        //   imageUrl: 'assets/images/image.png',
                        //   title: 'Content Title',
                        //   description: 'Content Description',
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard({
    required String imageUrl,
    required String title,
    required String description,
  }) {
    return SingleChildScrollView(
      child: Card(
        margin: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              height: 200, // Adjust the height according to your requirement
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

