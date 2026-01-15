import 'package:campus_care/features/domain/entities/personel_entity.dart';
import 'package:campus_care/features/domain/repositories/personel_repository.dart';

class GetPersonelUseCase {
  final PersonelRepository repository;
  GetPersonelUseCase(this.repository);

  Future<List<PersonelEntity>> call() {
    return repository.getPersonel();
  }
}

class CreatePersonelUseCase {
  final PersonelRepository repository;
  CreatePersonelUseCase(this.repository);

  Future<PersonelEntity> call({required CreatePersonelParams params}) {
    return repository.createPersonel(params.personel);
  }
}

class UpdatePersonelUseCase {
  final PersonelRepository repository;
  UpdatePersonelUseCase(this.repository);

  Future<PersonelEntity> call({required UpdatePersonelParams params}) {
    return repository.updatePersonel(params.personel);
  }
}

class DeletePersonelUseCase {
  final PersonelRepository repository;
  DeletePersonelUseCase(this.repository);

  Future<void> call({required DeletePersonelParams params}) {
    return repository.deletePersonel(params.id);
  }
}

class StreamPersonelUseCase {
  final PersonelRepository repository;
  StreamPersonelUseCase(this.repository);

  Stream<List<PersonelEntity>> call() {
    return repository.streamPersonel();
  }
}

class CreatePersonelParams {
  final PersonelEntity personel;
  CreatePersonelParams(this.personel);
}

class UpdatePersonelParams {
  final PersonelEntity personel;
  UpdatePersonelParams(this.personel);
}

class DeletePersonelParams {
  final String id;
  DeletePersonelParams(this.id);
}
