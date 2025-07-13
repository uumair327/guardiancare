import 'package:flutter/material.dart';
import 'package:guardiancare/src/features/explore/controllers/explore_controller.dart';
import 'package:guardiancare/src/common_widgets/pdf_viewer_page.dart';
import 'package:guardiancare/src/common_widgets/web_view_page.dart';
import 'package:guardiancare/src/features/explore/models/resource_model.dart'; // <- import your model

class RecommendedResources extends StatelessWidget {
  final ExploreController controller = ExploreController();

  RecommendedResources({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Resource>>(
      stream: controller.getRecommendedResources(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error loading resources');
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final resources = snapshot.data!;

        if (resources.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No resources available."),
          );
        }

        return ListView.builder(
          itemCount: resources.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final resource = resources[index];

            return ListTile(
              title: Text(resource.title),
              leading: Icon(
                  resource.type == 'pdf' ? Icons.picture_as_pdf : Icons.link),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                if (resource.type == 'pdf') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerPage(
                        pdfUrl: resource.url,
                        title: resource.title,
                      ),
                    ),
                  );
                } else if (resource.type == 'link') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPage(
                        url: resource.url,
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
