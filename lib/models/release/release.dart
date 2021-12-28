import 'package:json_annotation/json_annotation.dart';

import 'asset.dart';
import 'author.dart';

part 'release.g.dart';

@JsonSerializable()
class Release {
	String? url;
	@JsonKey(name: 'assets_url') 
	String? assetsUrl;
	@JsonKey(name: 'upload_url') 
	String? uploadUrl;
	@JsonKey(name: 'html_url') 
	String? htmlUrl;
	int? id;
	Author? author;
	@JsonKey(name: 'node_id') 
	String? nodeId;
	@JsonKey(name: 'tag_name') 
	String? tagName;
	@JsonKey(name: 'target_commitish') 
	String? targetCommitish;
	String? name;
	bool? draft;
	bool? prerelease;
	@JsonKey(name: 'created_at') 
	DateTime? createdAt;
	@JsonKey(name: 'published_at') 
	DateTime? publishedAt;
	List<Asset>? assets;
	@JsonKey(name: 'tarball_url') 
	String? tarballUrl;
	@JsonKey(name: 'zipball_url') 
	String? zipballUrl;
	String? body;

	Release({
		this.url, 
		this.assetsUrl, 
		this.uploadUrl, 
		this.htmlUrl, 
		this.id, 
		this.author, 
		this.nodeId, 
		this.tagName, 
		this.targetCommitish, 
		this.name, 
		this.draft, 
		this.prerelease, 
		this.createdAt, 
		this.publishedAt, 
		this.assets, 
		this.tarballUrl, 
		this.zipballUrl, 
		this.body, 
	});

	factory Release.fromJson(Map<String, dynamic> json) {
		return _$ReleaseFromJson(json);
	}

	Map<String, dynamic> toJson() => _$ReleaseToJson(this);
}
