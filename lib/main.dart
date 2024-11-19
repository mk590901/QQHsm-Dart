import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'list_bloc.dart';
/*
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Part List View with BLoC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => ListBloc(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<String> buttons = List.generate(10, (index) => 'Button $index');

  @override
  Widget build(BuildContext context) {

    Future.microtask(() {
      // Ensure this code runs after the build method completes
      //if (context != null) {
        print('******* INIT ENGINE *******');
        context.read<ListBloc>().add(AddItem('Initial Item'));
        // ApplicationHolder.holder()?.initSimulator(() {
        //   print ('******* REFRESH SIMULATION WIDGET *******');
        //   simulationWidget.refresh();
        // });
      //}
    });




    return Scaffold(
      appBar: AppBar(
        title: Text('Two Part List View with BLoC'),
      ),
      body: BlocListener<ListBloc, ListState>(
        listener: (context, state) {
          // Add an initial item to the list when the widget is built
          if (state is ListInitial) {
            context.read<ListBloc>().add(AddItem('Initial Item'));
          }
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ListBloc, ListState>(
                builder: (context, state) {
                  if (state is ListLoaded) {
                    return ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return Dismissible(
                          key: Key(item),
                          onDismissed: (direction) {
                            context.read<ListBloc>().add(DeleteItem(item));
                          },
                          background: Container(color: Colors.red),
                          child: ListTile(
                            title: Text(item),
                          ),
                        );
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Container(
              height: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: buttons.map((button) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ListBloc>().add(AddItem(button));
                        },
                        child: Text(button),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Part List View with BLoC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => ListBloc(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<String> buttons = List.generate(10, (index) => 'Button $index');

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {

    Future.microtask(() {
      // Ensure this code runs after the build method completes
      //if (context != null) {
      print('******* INIT ENGINE *******');
      context.read<ListBloc>().add(AddItem('Initial Item'));
      // ApplicationHolder.holder()?.initSimulator(() {
      //   print ('******* REFRESH SIMULATION WIDGET *******');
      //   simulationWidget.refresh();
      // });
      //}
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Part List View with BLoC'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ListBloc, ListState>(
              builder: (context, state) {
                if (state is ListLoaded) {
                  return ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          context.read<ListBloc>().add(DeleteItem(item));
                        },
                        background: Container(color: Colors.red),
                        child: ListTile(
                          title: Text(item),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          SizedBox(
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: buttons.map((button) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ListBloc>().add(AddItem(button));
                      },
                      child: Text(button),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Two Part List View with BLoC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => ListBloc(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<String> buttons = List.generate(10, (index) => 'Button $index');

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Part List View with BLoC'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ListBloc, ListState>(
              builder: (context, state) {
                if (state is ListLoaded) {
                  return ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(state.items[index]),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          SizedBox(
            height: 100,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: buttons.map((button) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<ListBloc>().add(AddItem(button));
                      },
                      child: Text(button),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

*/