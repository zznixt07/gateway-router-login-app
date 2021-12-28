import 'package:json_annotation/json_annotation.dart';

import 'uploader.dart';

part 'asset.g.dart';

@JsonSerializable()
class Asset {
	String? url;
	int? id;
	@JsonKey(name: 'node_id') 
	String? nodeId;
	String? name;
	String? label;
	Uploader? uploader;
	@JsonKey(name: 'content_type') 
	String? contentType;
	String? state;
	int? size;
	@JsonKey(name: 'download_count') 
	int? downloadCount;
	@JsonKey(name: 'created_at') 
	DateTime? createdAt;
	@JsonKey(name: 'updated_at') 
	DateTime? updatedAt;
	@JsonKey(name: 'browser_download_url') 
	String? browserDownloadUrl;

	Asset({
		this.url, 
		this.id, 
		this.nodeId, 
		this.name, 
		this.label, 
		this.uploader, 
		this.contentType, 
		this.state, 
		this.size, 
		this.downloadCount, 
		this.createdAt, 
		this.updatedAt, 
		this.browserDownloadUrl, 
	});

	factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);

	Map<String, dynamic> toJson() => _$AssetToJson(this);
}
