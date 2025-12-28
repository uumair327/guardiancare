# Implementation Plan: Animation Centralization

## Overview

This implementation plan centralizes animation patterns in the GuardianCare Flutter application following Clean Architecture and SOLID principles. The tasks are organized to build the core animation infrastructure first, then migrate feature widgets to use the centralized components.

## Tasks

- [x] 1. Create Animation Configuration Infrastructure
  - [x] 1.1 Create AnimationConfig class in `lib/core/animations/config/animation_config.dart`
    - Implement immutable class with duration, curve, begin, end properties
    - Implement copyWith method for customization
    - Implement toTween and createAnimation helper methods
    - Implement equality and hashCode
    - _Requirements: 3.1, 3.3_

  - [ ]* 1.2 Write property test for AnimationConfig immutability
    - **Property 3: AnimationConfig immutability**
    - **Validates: Requirements 3.3**

  - [x] 1.3 Create AnimationPresets class in `lib/core/animations/config/animation_presets.dart`
    - Define scaleButton preset (0.95 scale, short duration, tap curve)
    - Define scaleLarge preset (0.9 scale, short duration, tap curve)
    - Define fadeIn preset (0-1 opacity, medium duration, decelerate curve)
    - Define slideUp preset (30-0 offset, medium duration, decelerate curve)
    - _Requirements: 3.2_

  - [x] 1.4 Create HapticFeedbackType enum in `lib/core/animations/config/haptic_feedback_type.dart`
    - Define light, medium, heavy, selection variants
    - Implement trigger() method for each type
    - _Requirements: 1.4, 2.4_

  - [x] 1.5 Create config barrel export in `lib/core/animations/config/config.dart`
    - Export animation_config.dart, animation_presets.dart, haptic_feedback_type.dart
    - _Requirements: 3.1, 3.2_

- [x] 2. Enhance ScaleTapWidget
  - [x] 2.1 Update ScaleTapWidget to support AnimationConfig
    - Add optional config parameter
    - Add HapticFeedbackType parameter
    - Maintain backward compatibility with existing scaleDown parameter
    - Use AnimationPresets.scaleButton as default when no config provided
    - _Requirements: 1.1, 1.4, 1.5_

  - [ ] 2.2 Write property test for scale animation round-trip

    - **Property 1: Scale animation round-trip**
    - **Validates: Requirements 1.2, 1.3**

  - [ ]* 2.3 Write property test for disabled widget ignores input
    - **Property 2: Disabled widget ignores input**
    - **Validates: Requirements 1.6**

- [x] 3. Create AnimatedButton Widget
  - [x] 3.1 Create AnimatedButton in `lib/core/animations/animated_widgets/animated_button.dart`
    - Implement base AnimatedButton using ScaleTapWidget internally
    - Support custom child, onTap, config, haptic settings
    - Add padding and decoration support
    - _Requirements: 2.1, 2.3, 2.6_

  - [x] 3.2 Add AnimatedButton factory constructors
    - Implement AnimatedButton.icon() for icon-only buttons
    - Implement AnimatedButton.circular() for circular buttons
    - _Requirements: 2.2, 2.5_

  - [ ]* 3.3 Write unit tests for AnimatedButton configurations
    - Test icon-only, text-only, icon-with-text configurations
    - Test circular and rectangular variants
    - _Requirements: 2.2, 2.5_

- [x] 4. Create AppAnimatedContainer Widget
  - [x] 4.1 Create AppAnimatedContainer in `lib/core/animations/animated_widgets/app_animated_container.dart`
    - Wrap Flutter's AnimatedContainer
    - Set AppDurations.animationShort as default duration
    - Set AppCurves.standard as default curve
    - Support all standard Container properties
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [ ]* 4.2 Write unit tests for AppAnimatedContainer defaults
    - Verify default duration is AppDurations.animationShort
    - Verify default curve is AppCurves.standard
    - _Requirements: 5.2, 5.3_

- [x] 5. Enhance StaggeredListWidget
  - [x] 5.1 Update StaggeredListWidget with animation type support
    - Add StaggerAnimationType enum (fade, slide, fadeSlide, scale)
    - Support configurable item duration and stagger delay
    - Support both vertical and horizontal layouts
    - _Requirements: 6.1, 6.2, 6.3, 6.5_

  - [ ]* 5.2 Write property test for staggered animation timing
    - **Property 6: Staggered animation sequential timing**
    - **Validates: Requirements 6.4**

- [x] 6. Enhance AnimationControllerMixin
  - [x] 6.1 Update AnimationControllerMixin with multi-animation support
    - Add initAnimationFromConfig method
    - Add initScaleAnimation, initFadeAnimation, initSlideAnimation methods
    - Ensure proper disposal in all cases
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [ ]* 6.2 Write property test for controller disposal
    - **Property 5: Animation controller disposal**
    - **Validates: Requirements 4.3, 8.3**

- [x] 7. Update Barrel Exports
  - [x] 7.1 Update animated_widgets.dart barrel export
    - Add animated_button.dart export
    - Add app_animated_container.dart export
    - _Requirements: 2.1, 5.1_

  - [x] 7.2 Update animations.dart main barrel export
    - Add config/config.dart export
    - Ensure all new components are accessible via single import
    - _Requirements: 3.1, 3.2_

- [x] 8. Checkpoint - Core Animation System Complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Migrate Quiz Feature Widgets
  - [x] 9.1 Migrate OptionCard to use ScaleTapWidget
    - Replace manual AnimationController with ScaleTapWidget
    - Maintain identical visual behavior
    - Remove duplicate animation code
    - _Requirements: 7.1, 7.6_

  - [x] 9.2 Migrate QuizCard to use ScaleTapWidget
    - Replace manual AnimationController with ScaleTapWidget
    - Maintain identical visual behavior
    - _Requirements: 7.4, 7.6_

  - [ ]* 9.3 Write unit tests verifying migrated quiz widgets behavior
    - Test OptionCard tap animation
    - Test QuizCard tap animation
    - _Requirements: 7.6_

- [x] 10. Migrate Video Player Feature Widgets
  - [x] 10.1 Migrate VideoControlButton to use AnimatedButton
    - Replace manual AnimationController with AnimatedButton
    - Maintain identical visual behavior
    - _Requirements: 7.2, 7.6_

  - [x] 10.2 Migrate PlayPauseButton to use AnimatedButton
    - Replace manual AnimationController with AnimatedButton.circular
    - Maintain identical visual behavior
    - _Requirements: 7.3, 7.6_

  - [x] 10.3 Migrate _ActionButton and _QuickActionButton to use AnimatedButton
    - Replace manual AnimationController implementations
    - Maintain identical visual behavior
    - _Requirements: 7.5, 7.6_

  - [ ]* 10.4 Write unit tests verifying migrated video player widgets behavior
    - Test VideoControlButton tap animation
    - Test PlayPauseButton tap animation
    - _Requirements: 7.6_

- [x] 11. Replace Scattered AnimatedContainer Usages
  - [x] 11.1 Update video_progress_bar.dart to use AppAnimatedContainer
    - Replace AnimatedContainer with AppAnimatedContainer
    - Remove explicit duration/curve where defaults apply
    - _Requirements: 5.1_

  - [x] 11.2 Update quiz widgets to use AppAnimatedContainer
    - Replace AnimatedContainer in option_card.dart
    - Replace AnimatedContainer in quiz_card.dart
    - _Requirements: 5.1_

- [x] 12. Create Animation Test Utilities
  - [x] 12.1 Create AnimationTestUtils in `test/core/animations/animation_test_utils.dart`
    - Implement verifyAnimationComplete helper
    - Implement verifyAnimationValue helper
    - Implement simulatePressRelease helper
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

- [x] 13. Final Checkpoint - All Migrations Complete
  - Ensure all tests pass, ask the user if questions arise.
  - Verify no duplicate animation code remains in feature widgets
  - Verify all migrated widgets maintain identical visual behavior

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Migration tasks (9-11) should be done carefully to maintain visual parity
