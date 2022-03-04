import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todolist/model/todolist_model.dart';

class Todolist extends StatefulWidget {
  const Todolist({Key? key}) : super(key: key);

  @override
  State<Todolist> createState() => _TodolistState();
}

class _TodolistState extends State<Todolist> {
  late Box<TodolistModel> todoBox;
  @override
  void initState() {
    todoBox = Hive.box<TodolistModel>('todo_model');
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('TodoList'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: todoBox.listenable(),
              builder: (context, Box<TodolistModel> item, _) {
                List<int> keys = item.keys.cast<int>().toList();
                return ListView.builder(
                    itemCount: keys.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final key = keys[index];
                      final TodolistModel? _item = item.get(key);
                      return Slidable(
                        startActionPane:
                            ActionPane(motion: const ScrollMotion(), children: [
                          SlidableAction(
                            onPressed: ((context) =>
                                _todolistModel(context, null, key)),
                            backgroundColor: Colors.blue,
                            icon: Icons.edit,
                            label: 'Update',
                          )
                        ]),
                        endActionPane:
                            ActionPane(motion: const ScrollMotion(), children: [
                          SlidableAction(
                            onPressed: ((context) {
                              todoBox.deleteAt(index);
                            }),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          )
                        ]),
                        child: Card(
                          elevation: 5,
                          color: _item!.complete
                              ? Colors.greenAccent
                              : Colors.white,
                          child: ListTile(
                            title: Text(_item.title),
                            subtitle: Text(_item.details),

                            // leading: Text(_item.),
                            // trailing: IconButton(
                            //   icon: const Icon(Icons.delete),
                            //   onPressed: () {
                            //     todoBox.deleteAt(index);
                            //   },
                            // ),
                            onTap: () => _todolistModel(
                              null,
                              context,
                              key,
                            ),
                            onLongPress: () {
                              _markAsComplete(context, key);
                            },
                          ),
                        ),
                      );
                    });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _todolistModel(context, null, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _todolistModel(BuildContext? context1, context2, int? key) {
    if (key != null) {
      _titleController.text = todoBox.get(key)!.title;
      _detailsController.text = todoBox.get(key)!.details;
    }
    showDialog(
      context: context1 ?? context2,
      builder: (_) {
        return AlertDialog(
          title:
              key == null ? const Text('Add Work') : const Text('Update Items'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTextField(_titleController, 'Title'),
              const SizedBox(
                height: 10,
              ),
              _buildTextField(_detailsController, 'Details'),
            ],
          ),
          //let complete this
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                TodolistModel newValue = TodolistModel(
                    title: _titleController.text,
                    details: _detailsController.text,
                    complete: false);
                if (key == null) {
                  todoBox.add(newValue);
                } else {
                  todoBox.put(key, newValue);
                }
                _titleController.clear();
                _detailsController.clear();

                Navigator.of(context1 ?? context2, rootNavigator: true).pop();
              },
              child: key == null ? const Text('Add New') : const Text('Update'),
            )
          ],
        );
      },
    );
  }

  void _markAsComplete(BuildContext context, int? key) {
    if (key != null) {
      _titleController.text = todoBox.get(key)!.title;
      _detailsController.text = todoBox.get(key)!.details;
    }
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Mark as Complete'),
          content: const Text('Mark this task is Completed'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                TodolistModel newValue = TodolistModel(
                    title: _titleController.text,
                    details: _detailsController.text,
                    complete: true);
                todoBox.put(key, newValue);

                //clear all text
                _titleController.clear();
                _detailsController.clear();

                Navigator.of(context).pop();
              },
              child: const Text('Completed'),
            )
          ],
        );
      },
    );
  }

  TextField _buildTextField(TextEditingController _controller, String hint) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: hint,
        labelText: hint,
      ),
    );
  }
}
