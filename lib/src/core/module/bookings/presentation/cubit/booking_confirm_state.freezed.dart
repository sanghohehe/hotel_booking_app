// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_confirm_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BookingConfirmState {
  bool get isLoading => throw _privateConstructorUsedError;
  DateTime get checkIn => throw _privateConstructorUsedError;
  DateTime get checkOut => throw _privateConstructorUsedError;
  int get adults => throw _privateConstructorUsedError;
  int get children => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  BookingEntity? get successBooking => throw _privateConstructorUsedError;

  /// Create a copy of BookingConfirmState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingConfirmStateCopyWith<BookingConfirmState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingConfirmStateCopyWith<$Res> {
  factory $BookingConfirmStateCopyWith(
    BookingConfirmState value,
    $Res Function(BookingConfirmState) then,
  ) = _$BookingConfirmStateCopyWithImpl<$Res, BookingConfirmState>;
  @useResult
  $Res call({
    bool isLoading,
    DateTime checkIn,
    DateTime checkOut,
    int adults,
    int children,
    String? error,
    BookingEntity? successBooking,
  });
}

/// @nodoc
class _$BookingConfirmStateCopyWithImpl<$Res, $Val extends BookingConfirmState>
    implements $BookingConfirmStateCopyWith<$Res> {
  _$BookingConfirmStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingConfirmState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? checkIn = null,
    Object? checkOut = null,
    Object? adults = null,
    Object? children = null,
    Object? error = freezed,
    Object? successBooking = freezed,
  }) {
    return _then(
      _value.copyWith(
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            checkIn:
                null == checkIn
                    ? _value.checkIn
                    : checkIn // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            checkOut:
                null == checkOut
                    ? _value.checkOut
                    : checkOut // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            adults:
                null == adults
                    ? _value.adults
                    : adults // ignore: cast_nullable_to_non_nullable
                        as int,
            children:
                null == children
                    ? _value.children
                    : children // ignore: cast_nullable_to_non_nullable
                        as int,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
            successBooking:
                freezed == successBooking
                    ? _value.successBooking
                    : successBooking // ignore: cast_nullable_to_non_nullable
                        as BookingEntity?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookingConfirmStateImplCopyWith<$Res>
    implements $BookingConfirmStateCopyWith<$Res> {
  factory _$$BookingConfirmStateImplCopyWith(
    _$BookingConfirmStateImpl value,
    $Res Function(_$BookingConfirmStateImpl) then,
  ) = __$$BookingConfirmStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    DateTime checkIn,
    DateTime checkOut,
    int adults,
    int children,
    String? error,
    BookingEntity? successBooking,
  });
}

/// @nodoc
class __$$BookingConfirmStateImplCopyWithImpl<$Res>
    extends _$BookingConfirmStateCopyWithImpl<$Res, _$BookingConfirmStateImpl>
    implements _$$BookingConfirmStateImplCopyWith<$Res> {
  __$$BookingConfirmStateImplCopyWithImpl(
    _$BookingConfirmStateImpl _value,
    $Res Function(_$BookingConfirmStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookingConfirmState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? checkIn = null,
    Object? checkOut = null,
    Object? adults = null,
    Object? children = null,
    Object? error = freezed,
    Object? successBooking = freezed,
  }) {
    return _then(
      _$BookingConfirmStateImpl(
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        checkIn:
            null == checkIn
                ? _value.checkIn
                : checkIn // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        checkOut:
            null == checkOut
                ? _value.checkOut
                : checkOut // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        adults:
            null == adults
                ? _value.adults
                : adults // ignore: cast_nullable_to_non_nullable
                    as int,
        children:
            null == children
                ? _value.children
                : children // ignore: cast_nullable_to_non_nullable
                    as int,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
        successBooking:
            freezed == successBooking
                ? _value.successBooking
                : successBooking // ignore: cast_nullable_to_non_nullable
                    as BookingEntity?,
      ),
    );
  }
}

/// @nodoc

class _$BookingConfirmStateImpl extends _BookingConfirmState {
  const _$BookingConfirmStateImpl({
    this.isLoading = false,
    required this.checkIn,
    required this.checkOut,
    this.adults = 2,
    this.children = 0,
    this.error,
    this.successBooking,
  }) : super._();

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final DateTime checkIn;
  @override
  final DateTime checkOut;
  @override
  @JsonKey()
  final int adults;
  @override
  @JsonKey()
  final int children;
  @override
  final String? error;
  @override
  final BookingEntity? successBooking;

  @override
  String toString() {
    return 'BookingConfirmState(isLoading: $isLoading, checkIn: $checkIn, checkOut: $checkOut, adults: $adults, children: $children, error: $error, successBooking: $successBooking)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingConfirmStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut) &&
            (identical(other.adults, adults) || other.adults == adults) &&
            (identical(other.children, children) ||
                other.children == children) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.successBooking, successBooking) ||
                other.successBooking == successBooking));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    checkIn,
    checkOut,
    adults,
    children,
    error,
    successBooking,
  );

  /// Create a copy of BookingConfirmState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingConfirmStateImplCopyWith<_$BookingConfirmStateImpl> get copyWith =>
      __$$BookingConfirmStateImplCopyWithImpl<_$BookingConfirmStateImpl>(
        this,
        _$identity,
      );
}

abstract class _BookingConfirmState extends BookingConfirmState {
  const factory _BookingConfirmState({
    final bool isLoading,
    required final DateTime checkIn,
    required final DateTime checkOut,
    final int adults,
    final int children,
    final String? error,
    final BookingEntity? successBooking,
  }) = _$BookingConfirmStateImpl;
  const _BookingConfirmState._() : super._();

  @override
  bool get isLoading;
  @override
  DateTime get checkIn;
  @override
  DateTime get checkOut;
  @override
  int get adults;
  @override
  int get children;
  @override
  String? get error;
  @override
  BookingEntity? get successBooking;

  /// Create a copy of BookingConfirmState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingConfirmStateImplCopyWith<_$BookingConfirmStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
