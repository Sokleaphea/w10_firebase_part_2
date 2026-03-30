import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:w10_firebase_part_2/config/firebase_config.dart';

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
}
