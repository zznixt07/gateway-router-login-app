// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Release _$ReleaseFromJson(Map<String, dynamic> json) => Release(
      url: json['url'] as String?,
      assetsUrl: json['assets_url'] as String?,
      uploadUrl: json['upload_url'] as String?,
      htmlUrl: json['html_url'] as String?,
      id: json['id'] as int?,
      author: json['author'] == null
          ? null
          : Author.fromJson(json['author'] as Map<String, dynamic>),
      nodeId: json['node_id'] as String?,
      tagName: json['tag_name'] as String?,
      targetCommitish: json['target_commitish'] as String?,
      name: json['name'] as String?,
      draft: json['draft'] as bool?,
      prerelease: json['prerelease'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      assets: (json['assets'] as List<dynamic>)
          .map((e) => Asset.fromJson(e as Map<String, dynamic>))
          .toList(),
      tarballUrl: json['tarball_url'] as String?,
      zipballUrl: json['zipball_url'] as String?,
      body: json['body'] as String?,
    );

Map<String, dynamic> _$ReleaseToJson(Release instance) => <String, dynamic>{
      'url': instance.url,
      'assets_url': instance.assetsUrl,
      'upload_url': instance.uploadUrl,
      'html_url': instance.htmlUrl,
      'id': instance.id,
      'author': instance.author,
      'node_id': instance.nodeId,
      'tag_name': instance.tagName,
      'target_commitish': instance.targetCommitish,
      'name': instance.name,
      'draft': instance.draft,
      'prerelease': instance.prerelease,
      'created_at': instance.createdAt?.toIso8601String(),
      'published_at': instance.publishedAt?.toIso8601String(),
      'assets': instance.assets,
      'tarball_url': instance.tarballUrl,
      'zipball_url': instance.zipballUrl,
      'body': instance.body,
    };
