import 'package:life_log/database/db_config.dart';
import 'package:life_log/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:moment_dart/moment_dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _noteC = TextEditingController();

  final box = Hive.box('log');
  final db = Database();

  @override
  void initState() {
    db.loadData();
    super.initState();
  }

  @override
  void dispose() {
    _noteC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 248, 241),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        shadowColor: Colors.transparent,
        title: const Text(
          "Logs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingPage(),
                  ),
                );
                setState(() {});
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: db.notes.isEmpty
          ? const Center(child: Text("No logs available"))
          : MediaQuery.of(context).size.width >= 700
              ? LogByGridView(box: box, db: db)
              : LogByListView(
                  box: box,
                  db: db,
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 238, 230, 200),
        foregroundColor: Colors.black,
        onPressed: () {
          noteDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<dynamic> noteDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Add log",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: _noteC,
                    maxLines: 5,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Add your log",
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: MediaQuery.of(context).size.width >= 500
                          ? const EdgeInsets.symmetric(vertical: 20)
                          : EdgeInsets.zero,
                    ),
                    onPressed: () async {
                      if (_noteC.text == "") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Cannot submit blank log!"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }

                      final createdAtTime = DateTime.now();

                      db.notes.add(
                          {'body': _noteC.text, 'createdAt': createdAtTime});

                      db.updateDatabase();
                      setState(() {});

                      _noteC.text = "";
                      _noteC.clear();

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Log successfully added!"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      "Submit",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class LogByListView extends StatefulWidget {
  Box box;

  Database db;

  LogByListView({super.key, required this.box, required this.db});

  @override
  State<LogByListView> createState() => _LogByListViewState();
}

class _LogByListViewState extends State<LogByListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: widget.db.notes.length,
      itemBuilder: (context, index) {
        if (widget.db.notes.isEmpty) {
          return const Center(child: Text("No logs available"));
        }
        return Dismissible(
          key: ValueKey(UniqueKey()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 30),
            child: const Icon(Icons.delete),
          ),
          confirmDismiss: (direction) {
            return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  contentPadding: const EdgeInsets.all(30),
                  content: const Text(
                    "Are you sure to delete this log?",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget.db.notes.remove(
                                widget.db.notes.reversed.toList()[index]);
                          });

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Log deleted!"),
                              duration: Duration(seconds: 1),
                            ),
                          );

                          widget.db.updateDatabase();
                        },
                        child: const Text("Yes")),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("No")),
                  ],
                );
              },
            );
          },
          direction: DismissDirection.endToStart,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 10,
                        backgroundImage: AssetImage('images/user.png'),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.box.get('user_name'),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.db.notes.reversed.toList()[index]['body'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Divider(),
                  Text(
                    Moment(widget.db.notes.reversed.toList()[index]
                            ['createdAt'])
                        .calendar(),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class LogByGridView extends StatefulWidget {
  Box box;
  Database db;

  LogByGridView({super.key, required this.box, required this.db});

  @override
  State<LogByGridView> createState() => _LogByGridViewState();
}

class _LogByGridViewState extends State<LogByGridView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: widget.db.notes.isEmpty
            ? const Center(child: Text("No logs available"))
            : GridView.builder(
                padding: const EdgeInsets.all(30),
                itemCount: widget.db.notes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 256,
                ),
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 10,
                                    backgroundImage:
                                        AssetImage('images/user.png'),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.box.get('user_name'),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        contentPadding:
                                            const EdgeInsets.all(30),
                                        content: const Text(
                                          "Are you sure to delete this log?",
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  widget.db.notes.remove(widget
                                                      .db.notes.reversed
                                                      .toList()[index]);
                                                });

                                                Navigator.pop(context);

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content:
                                                        Text("Log deleted!"),
                                                    duration:
                                                        Duration(seconds: 1),
                                                  ),
                                                );

                                                widget.db.updateDatabase();
                                              },
                                              child: const Text("Yes")),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("No")),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                widget.db.notes.reversed.toList()[index]
                                    ['body'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const Divider(),
                          Text(
                            Moment(widget.db.notes.reversed.toList()[index]
                                    ['createdAt'])
                                .calendar(),
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
