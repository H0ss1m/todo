import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInstialStates());

  static AppCubit get(context) => BlocProvider.of(context);
}
