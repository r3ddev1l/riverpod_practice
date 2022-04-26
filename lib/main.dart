import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class WebsocketClient {
  Stream<int> getCounterStream([int start]);
}

class FakeWebsocketClient implements WebsocketClient {
  @override
  Stream<int> getCounterStream([int start = 0]) async* {
    int i = start;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield i++;
    }
  }
}

final websocketClientProvider =
    Provider<WebsocketClient>((ref) => FakeWebsocketClient());

final counterProvider =
    StreamProvider.autoDispose.family<int, int>((ref, start) {
  final wsClient = ref.watch(websocketClientProvider);

  return wsClient.getCounterStream(start);
});

// final counterProvider = StreamProvider<int>((ref) {
//   final wsClient = ref.watch(websocketClientProvider);

//   return wsClient.getCounterStream();
// });

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Counter App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Counter Page'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const CounterPage()),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CounterPage extends ConsumerWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> counter = ref.watch(counterProvider(5));

    // ref.listen<int>(
    //   counterProvider,
    //   (previous, next) {
    //     if (next >= 5) {
    //       showDialog(
    //           context: context,
    //           builder: (context) => AlertDialog(
    //                 title: const Text('Warning'),
    //                 content: const Text('Counter value is very high!'),
    //                 actions: [
    //                   TextButton(
    //                     onPressed: () {
    //                       Navigator.of(context).pop();
    //                     },
    //                     child: const Text("Ok"),
    //                   )
    //                 ],
    //               ));
    //     }
    //   },
    // );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
        actions: [
          IconButton(
              onPressed: () {
                ref.invalidate(counterProvider(2));
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: Center(
        child: Text(
          counter
              .when(
                  data: (int value) => value,
                  error: (Object error, _) => error,
                  loading: () => 5)
              .toString(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.add),
      //   onPressed: () {
      //     ref.read(counterProvider.notifier).state++;
      //   },
      // ),
    );
  }
}
