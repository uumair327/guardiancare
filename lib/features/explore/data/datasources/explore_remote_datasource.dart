import 'package:guardiancare/core/backend/backend.dart';
import 'package:guardiancare/features/explore/data/models/recommendation_model.dart';
import 'package:guardiancare/features/explore/data/models/resource_model.dart';

abstract class ExploreRemoteDataSource {
  Stream<List<RecommendationModel>> getRecommendations(String userId);
  Stream<List<ResourceModel>> getResources();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  ExploreRemoteDataSourceImpl({required IDataStore dataStore})
      : _dataStore = dataStore;
  final IDataStore _dataStore;

  @override
  Stream<List<RecommendationModel>> getRecommendations(String userId) {
    final options = QueryOptions(
      filters: [QueryFilter.equals('UID', userId)],
      orderBy: [const OrderBy('timestamp', descending: true)],
    );

    return _dataStore
        .streamQuery('recommendations', options: options)
        .map((result) {
      return result.when(
        success: (docs) => docs.map(RecommendationModel.fromMap).toList(),
        failure: (error) {
          // Provide feedback or log error? Returning empty list for now matching safe stream behavior
          return <RecommendationModel>[];
        },
      );
    });
  }

  @override
  Stream<List<ResourceModel>> getResources() {
    // Returning a curated list of high-quality resources
    // These are verified organizations and recognized authorities in child safety.
    final List<ResourceModel> curatedResources = [
      ResourceModel(
        id: 'child_rights_pdf',
        title: 'Child Rights Convention (PDF)',
        description:
            'Read the full text of the UN Convention on the Rights of the Child in this accessible PDF document.',
        url: 'https://pdfobject.com/pdf/sample.pdf',
        category: 'Document',
        type: 'pdf',
        timestamp: DateTime.now(),
      ),
      ResourceModel(
        id: 'safety_guide_custom',
        title: 'Interactive Safety Guide',
        description:
            'Learn about online safety through our interactive in-app guide with statistics and key information.',
        url: '',
        category: 'Guide',
        type: 'custom',
        timestamp: DateTime.now(),
        content: const {
          'title': 'Online Safety Guide',
          'description':
              'This comprehensive guide helps you understand the basics of digital safety. From secure passwords to recognizing phishing attempts, we cover essential topics for children and parents alike.\n\nStay safe, stay informed.',
          'stats': {
            'children': '10k+',
            'families': '5k+',
            'schools': '500+',
          },
        },
      ),
      ResourceModel(
        id: 'ncmec',
        title: 'National Center for Missing & Exploited Children',
        description:
            'The leading nonprofit organization in the U.S. working with law enforcement, families, and professionals to prevent child abduction and sexual exploitation.',
        url: 'https://www.missingkids.org',
        category: 'Organization',
        type: 'website',
        timestamp: DateTime.now(),
      ),
      ResourceModel(
        id: 'childline_india',
        title: 'Childline India - 1098',
        description:
            'India\'s first 24-hour, free, emergency phone service for children in need of aid and assistance. Operates 24/7.',
        url: 'https://www.childlineindia.org.in/',
        category: 'Emergency',
        type: 'helpline',
        timestamp: DateTime.now(),
      ),
      ResourceModel(
        id: 'thinkuknow',
        title: 'Thinkuknow - CEOP Education',
        description:
            'Education programme from the National Crime Agency\'s CEOP Command. Protects children both online and offline.',
        url: 'https://www.thinkuknow.co.uk/',
        category: 'Education',
        type: 'education',
        timestamp: DateTime.now(),
      ),
      ResourceModel(
        id: 'unicef_protection',
        title: 'UNICEF Child Protection',
        description:
            'Global initiatives by UNICEF to protect children from violence, exploitation, and abuse in over 190 countries.',
        url: 'https://www.unicef.org/protection',
        category: 'Organization',
        type: 'article',
        timestamp: DateTime.now(),
      ),
      ResourceModel(
        id: 'internet_matters',
        title: 'Internet Matters',
        description:
            'Expert advice and resources to help parents keep their children safe online. Covers social media, gaming, and privacy.',
        url: 'https://www.internetmatters.org/',
        category: 'Technology',
        type: 'guide',
        timestamp: DateTime.now(),
      ),
      ResourceModel(
        id: 'nspcc_uk',
        title: 'NSPCC - Prevention of Cruelty to Children',
        description:
            'Leading children\'s charity in the UK. Provides services for children and families and campaigns for child protection.',
        url: 'https://www.nspcc.org.uk/',
        category: 'Charity',
        type: 'website',
        timestamp: DateTime.now(),
      ),
      ResourceModel(
        id: 'safe_kids_worldwide',
        title: 'Safe Kids Worldwide',
        description:
            'Global organization dedicated to preventing injuries in children, the number one killer of kids in the United States and around the world.',
        url: 'https://www.safekids.org/',
        category: 'Safety',
        type: 'guide',
        timestamp: DateTime.now(),
      ),
    ];

    // Return as stream to match interface
    return Stream.value(curatedResources);
  }
}
