import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:w10_firebase_part_2/config/firebase_config.dart';
import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  static final Uri songUri = FirebaseConfig.baseUri.replace(path: 'songs.json');

  List<Song>? _cachedSong;
  @override
  Future<List<Song>> fetchSongs({ bool forceFetch = false }) async {
    if (_cachedSong != null && !forceFetch) {
      return _cachedSong!;
    }
    final http.Response response = await http.get(songUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      _cachedSong = result;
      return _cachedSong!;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {}

  @override
  Future<void> likeSong(String songId, int currentLike) async {
    final Uri likeSongUri = FirebaseConfig.baseUri.replace(
      path: '/songs/$songId.json',
    );

    final http.Response response = await http.patch(
      likeSongUri,
      headers: ({'Content-Type': 'application/json'}),
      body: json.encode({'likes': currentLike + 1}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to like song $songId');
    }
  }
}
