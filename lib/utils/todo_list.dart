import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:greydo/utils/util_colors.dart';

class TodoList extends StatefulWidget {
  const TodoList({
    super.key,
    required this.toDoList,
    required this.index,
    required this.taskCompleted,
    this.onChecked, required this.onDelete,
  });

  final List toDoList;
  final int index;
  final bool taskCompleted;
  final void Function(bool?)? onChecked;
  final VoidCallback onDelete;

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                widget.onDelete();
              },
              icon: Icons.delete,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: UtilColors.deePurpleColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Checkbox(
                checkColor: Colors.black,
                activeColor: Colors.white,
                side: BorderSide(color: Colors.white, ),
                value: widget.taskCompleted,
                onChanged: widget.onChecked,
              ),
              Expanded(
                child: Text(
                  widget.toDoList[widget.index][0],
                  // overflow: ,
                  style: TextStyle(color: Colors.white, fontSize: 18.0, decoration: widget.taskCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  decorationColor: Colors.red,
                  decorationThickness: 5.0,
                    decorationStyle: TextDecorationStyle.solid
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
