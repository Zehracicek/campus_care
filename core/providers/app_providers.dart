import 'package:campus_care/features/data/datasources/cloud/firebase_auth_datasource.dart';
import 'package:campus_care/features/data/repositories/academic_calendar_repository_impl.dart';
import 'package:campus_care/features/data/repositories/announcement_repository_impl.dart';
import 'package:campus_care/features/data/repositories/auth_repository_impl.dart';
import 'package:campus_care/features/data/repositories/building_repository_impl.dart';
import 'package:campus_care/features/data/repositories/campus_repository_impl.dart';
import 'package:campus_care/features/data/repositories/comment_repository_impl.dart';
import 'package:campus_care/features/data/repositories/demirbas_repository_impl.dart';
import 'package:campus_care/features/data/repositories/department_repository_impl.dart';
import 'package:campus_care/features/data/repositories/event_repository_impl.dart';
import 'package:campus_care/features/data/repositories/maintenance_category_repository_impl.dart';
import 'package:campus_care/features/data/repositories/maintenance_request_repository_impl.dart';
import 'package:campus_care/features/data/repositories/notification_repository_impl.dart';
import 'package:campus_care/features/data/repositories/personel_repository_impl.dart';
import 'package:campus_care/features/data/repositories/rating_repository_impl.dart';
import 'package:campus_care/features/data/repositories/room_repository_impl.dart';
import 'package:campus_care/features/data/repositories/user_repository_impl.dart';
import 'package:campus_care/features/data/repositories/user_role_repository_impl.dart';
import 'package:campus_care/features/domain/repositories/academic_calendar_repository.dart';
import 'package:campus_care/features/domain/repositories/announcement_repository.dart';
import 'package:campus_care/features/domain/repositories/auth_repository.dart';
import 'package:campus_care/features/domain/repositories/building_repository.dart';
import 'package:campus_care/features/domain/repositories/campus_repository.dart';
import 'package:campus_care/features/domain/repositories/comment_repository.dart';
import 'package:campus_care/features/domain/repositories/demirbas_repository.dart';
import 'package:campus_care/features/domain/repositories/department_repository.dart';
import 'package:campus_care/features/domain/repositories/event_repository.dart';
import 'package:campus_care/features/domain/repositories/maintenance_category_repository.dart';
import 'package:campus_care/features/domain/repositories/maintenance_request_repository.dart';
import 'package:campus_care/features/domain/repositories/notification_repository.dart';
import 'package:campus_care/features/domain/repositories/personel_repository.dart';
import 'package:campus_care/features/domain/repositories/rating_repository.dart';
import 'package:campus_care/features/domain/repositories/room_repository.dart';
import 'package:campus_care/features/domain/repositories/user_repository.dart';
import 'package:campus_care/features/domain/repositories/user_role_repository.dart';
import 'package:campus_care/features/domain/usecases/announcement_usecases.dart';
import 'package:campus_care/features/domain/usecases/auth_usecases.dart';
import 'package:campus_care/features/domain/usecases/category_usecases.dart';
import 'package:campus_care/features/domain/usecases/comment_usecases.dart';
import 'package:campus_care/features/domain/usecases/create_maintenance_request_usecase.dart';
import 'package:campus_care/features/domain/usecases/event_usecases.dart';
import 'package:campus_care/features/domain/usecases/get_maintenance_requests_usecase.dart';
import 'package:campus_care/features/domain/usecases/location_usecases.dart';
import 'package:campus_care/features/domain/usecases/notification_usecases.dart';
import 'package:campus_care/features/domain/usecases/personel_usecases.dart';
import 'package:campus_care/features/domain/usecases/stream_maintenance_requests_usecase.dart';
import 'package:campus_care/features/domain/usecases/update_maintenance_request_usecase.dart';
import 'package:campus_care/features/domain/usecases/update_request_status_usecase.dart';
import 'package:campus_care/features/domain/usecases/user_role_usecases.dart';
import 'package:campus_care/features/domain/usecases/user_usecases.dart';
import 'package:campus_care/features/presentation/controllers/academic_calendar_controller.dart';
import 'package:campus_care/features/presentation/controllers/announcement_controller.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:campus_care/features/presentation/controllers/category_controller.dart';
import 'package:campus_care/features/presentation/controllers/comment_controller.dart';
import 'package:campus_care/features/presentation/controllers/fixture_controller.dart';
import 'package:campus_care/features/presentation/controllers/department_controller.dart';
import 'package:campus_care/features/presentation/controllers/event_controller.dart';
import 'package:campus_care/features/presentation/controllers/maintenance_request_controller.dart';
import 'package:campus_care/features/presentation/controllers/notification_controller.dart';
import 'package:campus_care/features/presentation/controllers/personel_controller.dart';
import 'package:campus_care/features/presentation/controllers/rating_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Dependency Injection with Riverpod
/// State yönetimindeki providerlar burada tanımlanır. Direkt olarak state yönetiminin providerları burada tanımlanır
/// ,

// Firebase instances
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// DataSource Providers
final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authDatasource: ref.watch(firebaseAuthDatasourceProvider),
    firestore: ref.watch(firestoreProvider),
  );
});
final maintenanceRequestRepositoryProvider =
    Provider<MaintenanceRequestRepository>((ref) {
      return MaintenanceRequestRepositoryImpl(ref.watch(firestoreProvider));
    });

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepositoryImpl(ref.watch(firestoreProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(firestoreProvider));
});

final categoryRepositoryProvider = Provider<MaintenanceCategoryRepository>((
  ref,
) {
  return MaintenanceCategoryRepositoryImpl(ref.watch(firestoreProvider));
});

final campusRepositoryProvider = Provider<CampusRepository>((ref) {
  return CampusRepositoryImpl(ref.watch(firestoreProvider));
});

final buildingRepositoryProvider = Provider<BuildingRepository>((ref) {
  return BuildingRepositoryImpl(ref.watch(firestoreProvider));
});

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepositoryImpl(ref.watch(firestoreProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(firestoreProvider));
});

final userRoleRepositoryProvider = Provider<UserRoleRepository>((ref) {
  return UserRoleRepositoryImpl(ref.watch(firestoreProvider));
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(ref.watch(firestoreProvider));
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(ref.watch(firestoreProvider));
});

final personelRepositoryProvider = Provider<PersonelRepository>((ref) {
  return PersonelRepositoryImpl(ref.watch(firestoreProvider));
});

final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  return DepartmentRepositoryImpl(ref.watch(firestoreProvider));
});

final academicCalendarRepositoryProvider = Provider<AcademicCalendarRepository>(
  (ref) {
    return AcademicCalendarRepositoryImpl(ref.watch(firestoreProvider));
  },
);

final fixtureRepositoryProvider = Provider<FixtureRepository>((ref) {
  return FixtureRepositoryImpl(ref.watch(firestoreProvider));
});

final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepositoryImpl(ref.watch(firestoreProvider));
});

// UseCase Providers
final getMaintenanceRequestsUseCaseProvider =
    Provider<GetMaintenanceRequestsUseCase>((ref) {
      return GetMaintenanceRequestsUseCase(
        ref.watch(maintenanceRequestRepositoryProvider),
      );
    });

final getRequestsByUserUseCaseProvider = Provider<GetRequestsByUserUseCase>((
  ref,
) {
  return GetRequestsByUserUseCase(
    ref.watch(maintenanceRequestRepositoryProvider),
  );
});

final createMaintenanceRequestUseCaseProvider =
    Provider<CreateMaintenanceRequestUseCase>((ref) {
      return CreateMaintenanceRequestUseCase(
        ref.watch(maintenanceRequestRepositoryProvider),
      );
    });

final updateMaintenanceRequestUseCaseProvider =
    Provider<UpdateMaintenanceRequestUseCase>((ref) {
      return UpdateMaintenanceRequestUseCase(
        ref.watch(maintenanceRequestRepositoryProvider),
      );
    });

final updateRequestStatusUseCaseProvider = Provider<UpdateRequestStatusUseCase>(
  (ref) {
    return UpdateRequestStatusUseCase(
      ref.watch(maintenanceRequestRepositoryProvider),
    );
  },
);

final streamMaintenanceRequestsUseCaseProvider =
    Provider<StreamMaintenanceRequestsUseCase>((ref) {
      return StreamMaintenanceRequestsUseCase(
        ref.watch(maintenanceRequestRepositoryProvider),
      );
    });

final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>((ref) {
  return GetCommentsUseCase(ref.watch(commentRepositoryProvider));
});

final addCommentUseCaseProvider = Provider<AddCommentUseCase>((ref) {
  return AddCommentUseCase(ref.watch(commentRepositoryProvider));
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  return GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final getUnreadNotificationsUseCaseProvider =
    Provider<GetUnreadNotificationsUseCase>((ref) {
      return GetUnreadNotificationsUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final getEventsUseCaseProvider = Provider<GetEventsUseCase>((ref) {
  return GetEventsUseCase(ref.watch(eventRepositoryProvider));
});

final createEventUseCaseProvider = Provider<CreateEventUseCase>((ref) {
  return CreateEventUseCase(ref.watch(eventRepositoryProvider));
});

final updateEventUseCaseProvider = Provider<UpdateEventUseCase>((ref) {
  return UpdateEventUseCase(ref.watch(eventRepositoryProvider));
});

final deleteEventUseCaseProvider = Provider<DeleteEventUseCase>((ref) {
  return DeleteEventUseCase(ref.watch(eventRepositoryProvider));
});

final streamEventsUseCaseProvider = Provider<StreamEventsUseCase>((ref) {
  return StreamEventsUseCase(ref.watch(eventRepositoryProvider));
});

final getPersonelUseCaseProvider = Provider<GetPersonelUseCase>((ref) {
  return GetPersonelUseCase(ref.watch(personelRepositoryProvider));
});

final createPersonelUseCaseProvider = Provider<CreatePersonelUseCase>((ref) {
  return CreatePersonelUseCase(ref.watch(personelRepositoryProvider));
});

final updatePersonelUseCaseProvider = Provider<UpdatePersonelUseCase>((ref) {
  return UpdatePersonelUseCase(ref.watch(personelRepositoryProvider));
});

final deletePersonelUseCaseProvider = Provider<DeletePersonelUseCase>((ref) {
  return DeletePersonelUseCase(ref.watch(personelRepositoryProvider));
});

final streamPersonelUseCaseProvider = Provider<StreamPersonelUseCase>((ref) {
  return StreamPersonelUseCase(ref.watch(personelRepositoryProvider));
});

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsReadUseCase>((ref) {
      return MarkNotificationAsReadUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final getCategoriesByDepartmentUseCaseProvider =
    Provider<GetCategoriesByDepartmentUseCase>((ref) {
      return GetCategoriesByDepartmentUseCase(
        ref.watch(categoryRepositoryProvider),
      );
    });

final getAllCampusesUseCaseProvider = Provider<GetAllCampusesUseCase>((ref) {
  return GetAllCampusesUseCase(ref.watch(campusRepositoryProvider));
});

final getBuildingsByCampusUseCaseProvider =
    Provider<GetBuildingsByCampusUseCase>((ref) {
      return GetBuildingsByCampusUseCase(ref.watch(buildingRepositoryProvider));
    });

final getRoomsByBuildingUseCaseProvider = Provider<GetRoomsByBuildingUseCase>((
  ref,
) {
  return GetRoomsByBuildingUseCase(ref.watch(roomRepositoryProvider));
});

final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  return GetUserByIdUseCase(ref.watch(userRepositoryProvider));
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((
  ref,
) {
  return UpdateUserProfileUseCase(ref.watch(userRepositoryProvider));
});

final userRoleUseCaseProvider = Provider<GetRoleByIdUseCase>((ref) {
  return GetRoleByIdUseCase(ref.watch(userRoleRepositoryProvider));
});

final getAnnouncementsUseCaseProvider = Provider<GetAnnouncementsUseCase>((
  ref,
) {
  return GetAnnouncementsUseCase(ref.watch(announcementRepositoryProvider));
});

final createAnnouncementUseCaseProvider = Provider<CreateAnnouncementUseCase>((
  ref,
) {
  return CreateAnnouncementUseCase(ref.watch(announcementRepositoryProvider));
});

final updateAnnouncementUseCaseProvider = Provider<UpdateAnnouncementUseCase>((
  ref,
) {
  return UpdateAnnouncementUseCase(ref.watch(announcementRepositoryProvider));
});

final deleteAnnouncementUseCaseProvider = Provider<DeleteAnnouncementUseCase>((
  ref,
) {
  return DeleteAnnouncementUseCase(ref.watch(announcementRepositoryProvider));
});

final streamAnnouncementsUseCaseProvider = Provider<StreamAnnouncementsUseCase>(
  (ref) {
    return StreamAnnouncementsUseCase(
      ref.watch(announcementRepositoryProvider),
    );
  },
);

// Auth UseCase Providers
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final authStateChangesUseCaseProvider = Provider<AuthStateChangesUseCase>((
  ref,
) {
  return AuthStateChangesUseCase(ref.watch(authRepositoryProvider));
});

// Controller Providers
final authControllerProvider = StateNotifierProvider((ref) {
  return AuthController(
    ref.watch(signInUseCaseProvider),
    ref.watch(signUpUseCaseProvider),
    ref.watch(signOutUseCaseProvider),
    ref.watch(getCurrentUserUseCaseProvider),
  );
});
final maintenanceRequestControllerProvider = StateNotifierProvider((ref) {
  return MaintenanceRequestController(
    ref.watch(getMaintenanceRequestsUseCaseProvider),
    ref.watch(getRequestsByUserUseCaseProvider),
    ref.watch(createMaintenanceRequestUseCaseProvider),
    ref.watch(updateMaintenanceRequestUseCaseProvider),
    ref.watch(updateRequestStatusUseCaseProvider),
    ref.watch(streamMaintenanceRequestsUseCaseProvider),
  );
});
final categoryControllerProvider = Provider((ref) {
  return CategoryController(
    getCategoriesUseCase: ref.watch(getCategoriesUseCaseProvider),
    getCategoriesByDepartmentUseCase: ref.watch(
      getCategoriesByDepartmentUseCaseProvider,
    ),
  );
});

final notificationControllerProvider = Provider((ref) {
  return NotificationController(
    getNotificationsUseCase: ref.watch(getNotificationsUseCaseProvider),
    getUnreadNotificationsUseCase: ref.watch(
      getUnreadNotificationsUseCaseProvider,
    ),
    markNotificationAsReadUseCase: ref.watch(
      markNotificationAsReadUseCaseProvider,
    ),
  );
});

final commentControllerProvider = StateNotifierProvider((ref) {
  return CommentController(
    ref.watch(getCommentsUseCaseProvider),
    ref.watch(addCommentUseCaseProvider),
  );
});

final announcementControllerProvider = Provider((ref) {
  return AnnouncementController(
    getAnnouncementsUseCase: ref.watch(getAnnouncementsUseCaseProvider),
    createAnnouncementUseCase: ref.watch(createAnnouncementUseCaseProvider),
    updateAnnouncementUseCase: ref.watch(updateAnnouncementUseCaseProvider),
    deleteAnnouncementUseCase: ref.watch(deleteAnnouncementUseCaseProvider),
    streamAnnouncementsUseCase: ref.watch(streamAnnouncementsUseCaseProvider),
  );
});

final eventControllerProvider = StateNotifierProvider((ref) {
  return EventController(
    ref.watch(getEventsUseCaseProvider),
    ref.watch(createEventUseCaseProvider),
    ref.watch(updateEventUseCaseProvider),
    ref.watch(deleteEventUseCaseProvider),
    ref.watch(streamEventsUseCaseProvider),
  );
});

final personelControllerProvider = StateNotifierProvider((ref) {
  return PersonelController(
    ref.watch(getPersonelUseCaseProvider),
    ref.watch(createPersonelUseCaseProvider),
    ref.watch(updatePersonelUseCaseProvider),
    ref.watch(deletePersonelUseCaseProvider),
    ref.watch(streamPersonelUseCaseProvider),
  );
});

final departmentControllerProvider = StateNotifierProvider((ref) {
  return DepartmentController(ref.watch(departmentRepositoryProvider));
});

final academicCalendarControllerProvider = StateNotifierProvider((ref) {
  return AcademicCalendarController(
    ref.watch(academicCalendarRepositoryProvider),
  );
});

final fixtureControllerProvider = StateNotifierProvider((ref) {
  return FixtureController(ref.watch(fixtureRepositoryProvider));
});

final ratingControllerProvider = StateNotifierProvider((ref) {
  return RatingController(ref.watch(ratingRepositoryProvider));
});
