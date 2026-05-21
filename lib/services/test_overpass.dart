import 'package:http/http.dart' as http;

void main() async {
  final query = '[out:json][timeout:20];node["amenity"="bank"](around:5000,9.03,38.74);out center tags;';
  
  print('Trying GET...');
  try {
    final uriGet = Uri.parse('https://overpass-api.de/api/interpreter').replace(queryParameters: {'data': query});
    final resGet = await http.get(
      uriGet,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'EthioExploreApp/1.0',
      }
    );
    print('GET: ' + resGet.statusCode.toString() + ' ' + (resGet.reasonPhrase ?? ''));
  } catch (e) {
    print('GET failed: ' + e.toString());
  }

  print('Trying POST...');
  try {
    final resPost = await http.post(
      Uri.parse('https://overpass-api.de/api/interpreter'),
      body: {'data': query},
      headers: {
        'User-Agent': 'EthioExploreApp/1.0',
      }
    );
    print('POST form: ' + resPost.statusCode.toString() + ' ' + (resPost.reasonPhrase ?? ''));
  } catch (e) {
    print('POST failed: ' + e.toString());
  }
}
