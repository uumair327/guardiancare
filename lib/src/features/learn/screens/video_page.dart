import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../widgets/learn_view.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LearnBloc()..add(CategoriesRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Learn'),
        ),
        body: const LearnView(),
      ),
    );
  }
}
