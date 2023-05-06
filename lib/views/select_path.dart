import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'utils.dart';

class FisrtTab extends StatefulWidget{
  const FisrtTab({super.key});

  @override
  State<FisrtTab> createState() => FisrtTabState();
}

class FisrtTabState extends State<FisrtTab>{
  
  final String displayText = "ファイル選択";
  final String outputSample = "指定していないときはダウンロードフォルダ";
  String outMessage = "";
  final TextEditingController _userInputTextField = TextEditingController();
  final TextEditingController _outputPath = TextEditingController();
  // ignore: prefer_typing_uninitialized_variables
  var selectedFileInfo;
  static const SizedBox fixedHeight20SizedBox = SizedBox(height: 20,);
  static const SizedBox fixedWidth10SizedBox = SizedBox(width: 10,);

  @override
  void dispose(){
    _userInputTextField.dispose();
    _outputPath.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Column(
          children: [
            fixedHeight20SizedBox,
            Row(
              children: [
                fixedWidth10SizedBox,
                Expanded(child: makeTextField(_userInputTextField, displayText),),
                const SizedBox(width: 16,),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(onPressed: () async{
                      FilePickerResult? result = await FilePicker.platform.pickFiles(dialogTitle: "ファイル選択", withData: true);

                      if (result != null){
                        PlatformFile file = result.files.first;
                        _userInputTextField.text = file.path.toString();
                        selectedFileInfo = file;
                      }
                    },
                     child: const Text("File Select Button"))
                ),
                fixedWidth10SizedBox
              ],
            ),
            fixedHeight20SizedBox,
            makeOutputFolderSelectionArea(_outputPath, outputSample),
            fixedHeight20SizedBox,
            Row(
              children: [
                const SizedBox(width: 30,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // ファイルがpptxでない場合にエラーダイアログを出す
                      if(await isPPTX(selectedFileInfo.name) == false){
                        // ignore: use_build_context_synchronously
                        openFileErrorDialog(context);
                        // 入力内容をクリアする
                        setState(() {_userInputTextField.clear();});
                        return ;
                      } 
                      String s = await extractImagesFromPPTX(selectedFileInfo, _outputPath);
                      setState(() {outMessage = s;});
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(50),
                    ),
                    child: const Text("Extract Images from a PowerPoint file"),
                  ),
                ),
                const SizedBox(width: 30,)
              ],
            ),
            fixedHeight20SizedBox,
            Text(outMessage, style: const TextStyle(fontSize: 16))
          ],
        )
      ],
    );
  }
}
