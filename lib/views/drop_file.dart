import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'utils.dart';

class SecondTab extends StatefulWidget{
  const SecondTab({super.key});

  @override
  State<SecondTab> createState() => SecondTabState();
}

// 本当はここに変数を置くのはよくないがやり取り方法がわからなかったので苦肉の策としてここに置く
String? _filePath;

class SecondTabState extends State<SecondTab>{
  // ignore: prefer_typing_uninitialized_variables
  var selectedFileInfo;
  final String outputSample = "if not selected, automatically download folder";
  String outMessage = "";
  final TextEditingController _outputPath = TextEditingController();
  static const SizedBox fixedHeight14SizedBox = SizedBox(height: 14,);

  @override
  Widget build(BuildContext context){
    return Column(
        children: [
          Column(
            children: [
              fixedHeight14SizedBox,
              // Drag & Drop Area
              Row(
                children: const [
                  SizedBox(width: 10,),
                  Expanded(child: DragPPTX(),),
                  SizedBox(width: 10,),
                ],
              ),
              fixedHeight14SizedBox,
              // output folder selection area
              makeOutputFolderSelectionArea(_outputPath, outputSample),
              fixedHeight14SizedBox,
              Row(
                children: [
                  const SizedBox(width: 30,),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // ファイル名がpptxで終わらない場合にエラーダイアログを出す(本当は拡張子だけで判定するのは危険な気がするがとりあえずこれでやる)
                        // footnote: pptx以外のファイルの拡張子をpptxにされると危険
                        if(await isPPTX(_filePath!) == false){
                          // ignore: use_build_context_synchronously
                          openFileErrorDialog(context);
                          return ;
                        } 
                        // 拡張子がpptxの場合はデータを読み込む
                        selectedFileInfo = await XFile(_filePath.toString()).readAsBytes();
                        String s = await extractImagesFromPPTX(selectedFileInfo, _outputPath);
                        setState(() {outMessage = s;});
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size.fromHeight(50),
                      ),
                      child: const Text("Extract Images"),
                    ),
                  ),
                  const SizedBox(width: 30,)
                ],
              ),
              fixedHeight14SizedBox,
              Text(outMessage, style: const TextStyle(fontSize: 16)),
            ],
          ),
      ]
    );
  }
}

class DragPPTX extends StatefulWidget {
  const DragPPTX({Key? key}) : super(key: key);

  @override
  State<DragPPTX> createState() => _DragPPTXState();
}

class _DragPPTXState extends State<DragPPTX>{
  final List<XFile> _list = [];
  bool _dragging = false;
  Offset? offset;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) async {
        setState(() {
          if(detail.files.length >= 2){
            openNumOfFilesErrorDialog(context);
            offset = null;
            return ;
          }
          for(final file in detail.files){
            _list.add(file);
            _filePath = file.path;
          }
        });
      },
      onDragUpdated: (details) {
        setState(() {
          offset = details.localPosition;
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
          offset = detail.localPosition;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
          offset = null;
        });
      },
      child: Container(
        height: 200,
        color: _dragging || _list.isNotEmpty ? Colors.blue.withOpacity(0.4) : Colors.black12,
        child: Stack(
          children: [
            if (_list.isEmpty)
              const Center(child: Text("Drop here"))
            else
              Center(child: Text(_list.map((e) => e.path).join("\n")))
          ],
        ),
      ),
    );
  }
}