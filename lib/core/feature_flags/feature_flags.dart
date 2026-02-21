/// Feature Flags — Barrel Export
///
/// Import this single file to access the entire feature flag system:
///
/// ```dart
/// import 'package:guardiancare/core/feature_flags/feature_flags.dart';
/// ```
library;

export 'data/repositories/firebase_feature_flag_repository.dart';
export 'domain/entities/feature_flag_entity.dart';
export 'domain/entities/feature_flag_keys.dart';
export 'domain/repositories/i_feature_flag_repository.dart';
export 'presentation/cubit/feature_flag_cubit.dart';
export 'presentation/widgets/feature_gate.dart';
