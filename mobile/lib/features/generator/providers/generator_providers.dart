import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/generator_notifier.dart';

final generatorNotifierProvider =
    NotifierProvider<GeneratorNotifier, GeneratorState>(GeneratorNotifier.new);
