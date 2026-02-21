import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiancare/core/feature_flags/domain/entities/feature_flag_entity.dart';
import 'package:guardiancare/core/feature_flags/domain/repositories/i_feature_flag_repository.dart';
import 'package:guardiancare/core/util/logger.dart';

/// Firebase Firestore implementation of [IFeatureFlagRepository].
///
/// Reads from the `feature_flags` collection — the same collection
/// the CIF Dashboard writes to when an admin toggles a flag.
///
/// The [watchAll] stream updates in real-time via Firestore's
/// onSnapshot listener, so flag changes propagate instantly
/// without any app restart or manual refresh.
class FirebaseFeatureFlagRepository implements IFeatureFlagRepository {
  FirebaseFeatureFlagRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const _collection = 'feature_flags';

  /// Convert a raw Firestore document snapshot into a [FeatureFlagEntity].
  FeatureFlagEntity _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FeatureFlagEntity(
      key: doc.id,
      name: (data['name'] as String?) ?? doc.id,
      description: (data['description'] as String?) ?? '',
      enabled: (data['enabled'] as bool?) ?? true,
      category: (data['category'] as String?) ?? 'app',
      lastModifiedBy: data['lastModifiedBy'] as String?,
      lastModifiedAt: (data['lastModifiedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Stream<List<FeatureFlagEntity>> watchAll() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final flags = snapshot.docs.map(_fromDoc).toList();
      Log.d('[FeatureFlags] Received ${flags.length} flags from Firestore');
      return flags;
    }).handleError((Object error) {
      Log.e('[FeatureFlags] Stream error: $error');
    });
  }

  @override
  Future<List<FeatureFlagEntity>> getAll() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map(_fromDoc).toList();
    } on Object catch (e) {
      Log.e('[FeatureFlags] getAll error: $e');
      return [];
    }
  }
}
