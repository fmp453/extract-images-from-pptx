import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'alert.dart';

TextField makeTextField(TextEditingController tec, String displayText){
  return TextField(
    readOnly: true,
    controller: tec,
    decoration: InputDecoration(
      border: const OutlineInputBorder(),
      labelText: displayText
    ),
  );
}

Row makeOutputFolderSelectionArea(TextEditingController outputPath, String outputSample){
  return Row(
    children: [
      const SizedBox(width: 10,),
      Expanded(child: makeTextField(outputPath, outputSample),),
      const SizedBox(width: 16,),
      SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: () async {
            String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle: "フォルダ選択");
            if(selectedDirectory != null){
              outputPath.text = selectedDirectory;
            }
          },
          child: const Text("Foder Select Button"),
        )
      ),
      const SizedBox(width: 10,)
    ],
  );
}

// 汎用的にCustomAlertDialogを呼び出すための関数
// 各アラート呼び出し関数の中でのみ使われる
void openCustomAlertDialog({
  required BuildContext context,
  required String title,
  required Text contentWidget,
  required String defaultActionText
  }){
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return CustomAlertDialog(title: title, contentWidget: contentWidget, defaultActionText: defaultActionText);
    }
  );
}

// 拡張子チェック
void openFileErrorDialog(BuildContext context){
  openCustomAlertDialog(
    context: context, 
    title: "File Type Error", 
    contentWidget: const Text("File type must be pptx"), 
    defaultActionText: "OK",
  );
}

// ファイル数チェック
void openNumOfFilesErrorDialog(BuildContext context){
  openCustomAlertDialog(
    context: context,
    title: "Number of Files Error",
    contentWidget: const Text("Cannot handle mutiple files at once."),
    defaultActionText: "OK",
  );
}

Future<String> extractImagesFromPPTX(dynamic targetFile, TextEditingController tec) async{
  await fromPPTX2ZIP(targetFile);
  await unzip(tec);
  String s = await removeDirsAndFiles(tec);
  return s;
}

// 本当はファイル形式を確認すべきだがここでは拡張子を見る
Future<bool> isPPTX(String fileName) async{
  int n = fileName.length;
  return fileName.substring(n - 4, n) == "pptx";
}

Future<void> fromPPTX2ZIP(dynamic targetFile) async {
  final Directory? downloadsDir = await getDownloadsDirectory();
  if(downloadsDir != null){
    // Download folderに保存
    // pathを指定した時とdrag&dropの時で型が違うので型チェックをしてデータを渡す
    var bytes;
    if(targetFile is PlatformFile){
      bytes = Uint8List.fromList(targetFile.bytes as List<int>);
    } else if(targetFile is Uint8List){
      bytes = targetFile;
    }

    await FileSaver.instance.saveFile(
        name: "sample",
        bytes: bytes,
        ext: "zip",
        mimeType: MimeType.zip
    );
  }
}

Future<void> unzip(TextEditingController tec) async {
  // String zipPath = "${tec.text}/sample.zip";
  final Directory? downloadsDir = await getDownloadsDirectory();
  if(downloadsDir == null){
    return ;
  }
  String targetDirName = downloadsDir.path;
  if(tec.text != ""){
    targetDirName = tec.text;
  }
  String zipPath = "${downloadsDir.path}/sample.zip";
  if(await File(zipPath).exists()){
    var process = await Process.run("unzip",
      [
        "-o", zipPath,
        "-d", "$targetDirName/sample"
      ],
      workingDirectory: path.dirname(targetDirName)
    );
    // 本当はログファイルなどに出力すべき
    if(process.exitCode != 0){
      debugPrint("Error");
      debugPrint(targetDirName);
      debugPrint(zipPath);
      debugPrint(process.stderr);
    }
  }
}

Future<String> removeDirsAndFiles(TextEditingController tec) async{
  final Directory? downloadsDir = await getDownloadsDirectory();
  if(downloadsDir == null){
    return "No Download Dir";
  }
  String zipPath = "${downloadsDir.path}/sample";
  if(tec.text != ""){
    zipPath = "${tec.text}/sample";
  }
  if(await Directory(zipPath).exists()){
    // zipを解凍したときに出る無駄なものを削除
    removeDirectoryRec("$zipPath/_rels", zipPath);
    removeDirectoryRec("$zipPath/docProps", zipPath);
    removeFile("$zipPath/[Content_Types].xml", zipPath);
    moveDirectory("$zipPath/ppt/media", "$zipPath/", zipPath);
    removeDirectoryRec("$zipPath/ppt", zipPath);
    removeFile("${downloadsDir.path}/sample.zip", downloadsDir.path);
    // mediaの中にある画像(実際はすべてのファイル)を移動してからmediaフォルダを削除する
    // awaitなしだとremoveDirectoryRec("$zipPath/media", zipPath)の方が先に実行される
    await moveFiles("$zipPath/media", zipPath);
    removeDirectoryRec("$zipPath/media", zipPath);
    return "$zipPathに保存しました";
  }
  return "Failed";
}

void printError(ProcessResult process){
  if(process.exitCode != 0){
    debugPrint(process.stderr.toString());
  }
}

Future<void> removeDirectoryRec(String dirName, String excutablePath) async{
  var process = await Process.run("rm",  ["-r", dirName], workingDirectory: path.dirname(excutablePath));
  printError(process);
}

Future<void> removeFile(String fileName, String excutablePath) async{
  var process = await Process.run("rm", [fileName], workingDirectory: path.dirname(excutablePath));
  printError(process);
}

Future<void> moveDirectory(String dirName, String targetDirName, String excutablePath) async{
  var process = await Process.run("mv", [dirName, targetDirName], workingDirectory: path.dirname(excutablePath));
  printError(process);
}

Future<void> moveFiles(String sourceDirName, String targetDirName) async{
  var sourceDir = Directory(sourceDirName);
  await for(var value in sourceDir.list()){
    final String fileName = path.basename(value.path);
    value.rename("$targetDirName/$fileName");
  }
}