import 'package:flutter/material.dart';

class ListContactFragment extends StatelessWidget {
  final List<dynamic> data;
  const ListContactFragment({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item  = data[index];
            return ListTile(
              title: Text(item['name'] ?? 'No Name'),
              subtitle: Text(item['email'] ?? 'No Email'),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(item['avatar'] ?? ''),
              ),
              onTap: () {
                print('Tapped on ${item['name']}');
              },
            );
          }),
    );
  }
}