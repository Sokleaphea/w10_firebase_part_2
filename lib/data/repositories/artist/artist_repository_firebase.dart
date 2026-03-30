import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:w10_firebase_part_2/config/firebase_config.dart';
import 'package:w10_firebase_part_2/data/dtos/comment_dto.dart';
import 'package:w10_firebase_part_2/data/dtos/song_dto.dart';
import 'package:w10_firebase_part_2/model/comment/comment.dart';
import 'package:w10_firebase_part_2/model/songs/song.dart';

import '../../../model/artist/artist.dart';
import '../../dtos/artist_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  static final Uri artistUri = FirebaseConfig.baseUri.replace(
    path: 'artists.json',
  );
  List<Artist>? _cacheArtist;
  @override
  Future<List<Artist>> fetchArtists({bool forceFetch = false}) async {
    if (_cacheArtist != null && !forceFetch) {
      return _cacheArtist!;
    }
    final http.Response response = await http.get(artistUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Artist> result = [];
      for (final entry in songJson.entries) {
        result.add(ArtistDto.fromJson(entry.key, entry.value));
      }
      _cacheArtist = result;
      return _cacheArtist!;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {}

  @override
  Future<List<Song>> fetchSongsByArtist(String artistId) async {
    final Uri songsUri = FirebaseConfig.baseUri.replace(
      path: 'songs.json',
      queryParameters: {'orderBy': '"artistId"', 'equalTo': '"$artistId"'},
    );
    print('Fetching songs from: $songsUri');
    final http.Response response = await http.get(songsUri);
    if (response.statusCode != 200) {
        print('Songs fetch failed: ${response.statusCode}');
        return [];
      }
      if (response.body == 'null') return [];
    if (response.statusCode == 200) {
      Map<String, dynamic> songsJson = json.decode(response.body);
      List<Song> result = [];
      for (final entry in songsJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      return result;
    } else {
      throw Exception('Failed to load artist songs for $artistId');
    }
  }

  @override
  Future<List<Comment>> fetchCommentByArtist(String artistId) async {
    final Uri commentsUri = FirebaseConfig.baseUri.replace(
      path: '/comments.json',
      queryParameters: {'orderBy': '"artistId"', 'equalTo': '"$artistId"'},
    );
    final http.Response response = await http.get(commentsUri);
    if (response.statusCode == 200) {
      Map<String, dynamic> commentsJson = json.decode(response.body);
      List<Comment> result = [];
      for (final entry in commentsJson.entries) {
        result.add(CommentDto.fromJson(entry.key, entry.value));
      }
      return result;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Future<void> postComment(String artistId, Comment comment) async {
    final Uri commentUri = FirebaseConfig.baseUri.replace(
      path: '/comments.json',
    );

    final http.Response response = await http.post(
      commentUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(CommentDto.toJson(artistId, comment.text)),
    );
    if (response.statusCode != 200) {
      throw Exception('Falied to post a comment');
    }
  }
}
