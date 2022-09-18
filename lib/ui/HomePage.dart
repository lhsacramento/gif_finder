import 'dart:convert';

import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? _search;
  int _offSet = 0;

  Future<Map> _getGifs () async{
    http.Response response;

    if(_search == null) {
      response = await http.get(Uri.parse('https://api.giphy.com/v1/gifs/trending?api_key=KVy1wkN9RolHRx4N6HSVa4rslQTTjx57&limit=20&rating=g'));
    }else{
      response = await http.get(Uri.parse('https://api.giphy.com/v1/gifs/search?api_key=KVy1wkN9RolHRx4N6HSVa4rslQTTjx57&q=$_search&limit=19&offset=$_offSet&rating=g&lang=en'));
    }
    return json.decode(response.body);
  }

  @override
  void initState(){
    super.initState();
    _getGifs().then((map){
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Pesquise Aqui!',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)
                ),
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color:Colors.white,fontSize: 18),
              textAlign: TextAlign.center,
              onSubmitted: (text){
                setState((){
                  _search = text;
                  _offSet = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: (context,snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          valueColor:AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5,
                        ),
                      );
                    default:
                      if(snapshot.hasError) {
                        return Container(
                          child: Text('Houve um problema ao carregar os Gifs!'),
                        );
                      }
                      else {
                        return _createGifTable(context, snapshot);
                      }
                  }
                },
              )
          ),
        ],
      ),
    );
  }

  int _getCount(List data){
    if(_search == null){
      return data.length;
    }else{
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot){
      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context,index){
          if(_search == null || index < snapshot.data["data"].length){
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                  fit: BoxFit.cover,
              ),
              onTap: (){
                Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index])));
              },
              onLongPress: (){
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
                //Share.shareFiles(snapshot.data["data"][index]["images"]["fixed_height"]["mp4"]);
              },
            );
          }else{
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add,color: Colors.white,size: 70,),
                    Text('Show more gifs...', style:TextStyle(color: Colors.white,fontSize: 15)),
                ],
                ),
                onTap: (){
                  setState((){
                    _offSet += 19;
                  });
                },
              ),
            );
          }

        }
      );
  }
}
