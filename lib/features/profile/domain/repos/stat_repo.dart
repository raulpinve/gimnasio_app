import 'package:gym_app/features/profile/domain/entities/stats.dart';

abstract class StatRepo {
  Future<Stats> getStat();
}
