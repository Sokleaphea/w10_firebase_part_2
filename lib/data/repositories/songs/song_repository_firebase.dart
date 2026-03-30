import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:w10_firebase_part_2/config/firebase_config.dart';
import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  // final Uri songsUri = Uri.https(
  //   'w8-practice-53cd2-default-rtdb.asia-southeast1.firebasedatabase.app',
  //   '/songs.json',
  // );
  static final Uri songUri = FirebaseConfig.baseUri.replace(path: 'songs.json');
  @override
  Future<List<Song>> fetchSongs() async {
    final http.Response response = await http.get(songUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      return result;
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
      body: json.encode({'like': currentLike + 1})
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to like song $songId');
    }
    
  }
}
