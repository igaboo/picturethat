import 'package:flutter/material.dart';
import 'package:picturethat/widgets/prompt.dart';

class PromptsScreen extends StatelessWidget {
  const PromptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0.0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text("Submit Today's Prompt"),
        icon: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          spacing: 30.0,
          children: [
            Prompt(
              id: "1",
              imageUrl:
                  "https://images.unsplash.com/photo-1742426426875-4c16b5f4e95e?q=80&w=1288&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              title: "Apocalypse",
              submissionCount: 1933,
              date: DateTime.now(),
            ),
            Prompt(
              id: "1",
              imageUrl:
                  "https://images.unsplash.com/photo-1741524916504-c0612094115e?q=80&w=1118&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              title: "Pareidolia",
              submissionCount: 1553391,
              date: DateTime.now().subtract(Duration(days: 1)),
            ),
            Prompt(
              id: "1",
              imageUrl:
                  "https://images.unsplash.com/photo-1613219332203-8513309bd7a6?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              title: "Monochrome",
              submissionCount: 25,
              date: DateTime.now().subtract(Duration(days: 2)),
            ),
            Prompt(
              id: "1",
              imageUrl:
                  "https://images.unsplash.com/photo-1742783199458-aa2ec62ae5f5?q=80&w=1315&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              title: "Texture",
              submissionCount: 3345,
              date: DateTime.now().subtract(Duration(days: 3)),
            ),
            Prompt(
              id: "1",
              imageUrl:
                  "https://images.unsplash.com/photo-1742435456486-3a0059c05e38?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
              title: "Tiled",
              submissionCount: 0,
              date: DateTime.now().subtract(Duration(days: 4)),
            ),
          ],
        ),
      ),
    );
  }
}
