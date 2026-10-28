import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trvlez_mobile/core/network/dio_error_mapper.dart';
import 'package:trvlez_mobile/features/findr/data/datasources/finder_remote_data_source.dart';
import 'package:trvlez_mobile/features/findr/data/models/finder_dto.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_activation_params.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_status.dart';
import 'package:trvlez_mobile/features/findr/domain/entities/finder_terms.dart';
import 'package:trvlez_mobile/features/findr/domain/repositories/finder_repository.dart';

/// Concrete repository implementation that coordinates Finder data and maps exceptions.
class FinderRepositoryImpl implements FinderRepository {
  const FinderRepositoryImpl({required this.remoteDataSource});

  final FinderRemoteDataSource remoteDataSource;

  @override
  Future<FinderStateSummary> getFinderStatus() async {
    try {
      final responseDto = await remoteDataSource.getFinderStatus();
      return responseDto.toDomain();
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }

  @override
  FinderTerms getFinderTerms() {
    return FinderTerms.defaultTerms;
  }

  @override
  Future<FinderIdentity> activateFinder(FinderActivationParams params) async {
    try {
      final requestDto = FinderActivationRequestDto.fromDomain(params);
      final responseDto = await remoteDataSource.activateFinder(requestDto);
      return responseDto.toDomain();
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }

  @override
  Future<FinderIdentity> updateProfile(FinderProfileUpdateParams params) async {
    try {
      final requestDto = FinderProfileUpdateDto.fromDomain(params);
      final responseDto = await remoteDataSource.updateProfile(requestDto);
      return responseDto.toDomain();
    } on DioException catch (dioException) {
      throw mapDioException(dioException);
    }
  }
}

/// Provider for [FinderRepository].
final finderRepositoryProvider = Provider<FinderRepository>((ref) {
  return FinderRepositoryImpl(
    remoteDataSource: ref.watch(finderRemoteDataSourceProvider),
  );
});
