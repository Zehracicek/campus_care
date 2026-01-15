import 'package:campus_care/features/domain/entities/personel_entity.dart';

abstract class PersonelRepository {
  Future<List<PersonelEntity>> getPersonel();
  Future<PersonelEntity> createPersonel(PersonelEntity personel);
  Future<PersonelEntity> updatePersonel(PersonelEntity personel);
  Future<void> deletePersonel(String id);
  Stream<List<PersonelEntity>> streamPersonel();
}
