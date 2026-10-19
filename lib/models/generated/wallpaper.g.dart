// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../wallpaper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WallpaperProps _$WallpaperPropsFromJson(Map<String, dynamic> json) =>
    _WallpaperProps(
      enabled: json['enabled'] as bool? ?? false,
      fileName: json['fileName'] as String?,
      library:
          (json['library'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      fit:
          $enumDecodeNullable(_$WallpaperFitEnumMap, json['fit']) ??
          WallpaperFit.cover,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      positionX: (json['positionX'] as num?)?.toDouble() ?? 0.0,
      positionY: (json['positionY'] as num?)?.toDouble() ?? 0.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.35,
      dimming: (json['dimming'] as num?)?.toDouble() ?? 0.0,
      blur: (json['blur'] as num?)?.toDouble() ?? 0.0,
      cardOpacity: (json['cardOpacity'] as num?)?.toDouble() ?? 0.9,
    );

Map<String, dynamic> _$WallpaperPropsToJson(_WallpaperProps instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'fileName': instance.fileName,
      'library': instance.library,
      'fit': _$WallpaperFitEnumMap[instance.fit]!,
      'scale': instance.scale,
      'positionX': instance.positionX,
      'positionY': instance.positionY,
      'opacity': instance.opacity,
      'dimming': instance.dimming,
      'blur': instance.blur,
      'cardOpacity': instance.cardOpacity,
    };

const _$WallpaperFitEnumMap = {
  WallpaperFit.cover: 'cover',
  WallpaperFit.contain: 'contain',
  WallpaperFit.fill: 'fill',
};
