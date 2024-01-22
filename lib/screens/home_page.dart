import 'package:flutter/material.dart';
import 'package:studize_interview/services/tasks/tasks_classes.dart';
import 'package:studize_interview/services/tasks/tasks_service.dart';
import 'package:studize_interview/widgets/date_picker.dart';
import 'package:studize_interview/widgets/task_timeline.dart';
import 'package:studize_interview/widgets/task_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingValue = screenWidth > 650 ? 15.0 : 10.0;
    final fontSizeValue = screenWidth > 650 ? 18.0 : 14.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DatePicker(
              callback: (selectedDay) => setState(() => this.selectedDay = selectedDay),
            ),
            SubjectsGrid(paddingValue: paddingValue, fontSizeValue: fontSizeValue),
            FutureBuilder<List<Task>>(
              future: TasksService.getAllTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final List<Task> taskList = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TaskTitle(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: taskList.length,
                      itemBuilder: (context, index) => TaskTimeline(
                        task: taskList[index],
                        subjectColor: taskList[index].color,
                        isFirst: index == 0,
                        isLast: index == taskList.length - 1,
                        refreshCallback: () {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectsGrid extends StatelessWidget {
  final Future<List<Subject>> _subjectListFuture = TasksService.getSubjectList();
  final double paddingValue;
  final double fontSizeValue;

  SubjectsGrid({Key? key, required this.paddingValue, required this.fontSizeValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<Subject>>(
      future: _subjectListFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Subject>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            List<Subject> subjectList = snapshot.data ?? [];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjectList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth > 650 ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) => _buildSubject(context, subjectList[index]),
            );
          case ConnectionState.waiting:
          case ConnectionState.active:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.none:
            return const Center(
              child: Text("Error: Could not get subjects from storage"),
            );
        }
      },
    );
  }

  Widget _buildSubject(BuildContext context, Subject subject) {
    return GestureDetector(
      onTap: () {
        // Do nothing
      },
      child: Container(
        padding: EdgeInsets.all(paddingValue),
        decoration: BoxDecoration(
          color: subject.color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              subject.iconAssetPath,
              width: 35,
              height: 35,
            ),
            const SizedBox(height: 5),
            Text(
              subject.name,
              style: TextStyle(
                fontSize: fontSizeValue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTaskStatus(
                  Colors.black,
                  subject.color,
                  '${subject.numTasksLeft} left',
                  Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatus(
      Color bgColor,
      Color txColor,
      String text,
      Color textColor,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
        ),
      ),
    );
  }
}
