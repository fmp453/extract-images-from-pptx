import 'package:flutter/material.dart';

import 'views/select_path.dart';
import 'views/drop_file.dart';

void main() {
  runApp(const MyApp());
}

// TabごとにUIを作る
// viewsフォルダにタブごとのファイルを作成

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extracting Images From PowerPoint File',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Extract images from PowerPoint file'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const String version = '0.1.0';
class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  late TabController tabController;
  Color appBarBackgroundColor = Colors.green;

  @override
  void initState() {
    super.initState();

    // タブが切り替わったとき、タブに応じてヘッダーの背景色を変える
    tabController = TabController(length: 2,vsync: this);
    tabController.addListener(() {
      setState(() {
        switch (tabController.index) {
          case 0:
            appBarBackgroundColor = Colors.green;
            break;
          case 1:
            appBarBackgroundColor = Colors.lightBlue;
            break;
        }
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        title: Text(widget.title),
        actions: const [
          Center(
            child: Text('version $version', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'パスの指定'),
            Tab(text: 'D&D'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: const [
          FisrtTab(),
          SecondTab(),
        ],
      ),
    );
  }
}