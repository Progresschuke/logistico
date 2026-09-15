import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

// ============================================================
// MODEL
// ============================================================

class User {
  final int id;
  final String name;
  final String username;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}

// ============================================================
// API SERVICE
// ============================================================

class ApiService {
  final http.Client client;

  ApiService({required this.client});

  Future<List<User>> fetchUsers() async {
    final response = await client.get(
      Uri.parse('https://jsonplaceholder.typicode.com/users'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

// ============================================================
// API PROVIDER
// ============================================================

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(client: http.Client());
});

// ============================================================
// REPOSITORY
// ============================================================

class UserRepository {
  final ApiService apiService;

  UserRepository({required this.apiService});

  Future<List<User>> getUsers() {
    return apiService.fetchUsers();
  }
}

// ============================================================
// REPOSITORY PROVIDER
// ============================================================

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);

  return UserRepository(apiService: apiService);
});

// ============================================================
// USERS PROVIDER
// ============================================================

final usersProvider = FutureProvider<List<User>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);

  return repository.getUsers();
});

// ============================================================
// SCREEN
// ============================================================

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(usersProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: usersAsync.when(
        // ----------------------------------------------------
        // LOADING
        // ----------------------------------------------------
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        // ----------------------------------------------------
        // ERROR
        // ----------------------------------------------------
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),

                  const SizedBox(height: 16),

                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(error.toString(), textAlign: TextAlign.center),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(usersProvider);
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        },

        // ----------------------------------------------------
        // DATA
        // ----------------------------------------------------
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(usersProvider);

              // Wait until the refreshed provider finishes.
              await ref.read(usersProvider.future);
            },

            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),

              itemCount: users.length,

              separatorBuilder: (_, __) {
                return const Divider(height: 1);
              },

              itemBuilder: (context, index) {
                final user = users[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name.substring(0, 1).toUpperCase()),
                  ),

                  title: Text(user.name),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('@${user.username}'), Text(user.email)],
                  ),

                  isThreeLine: true,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// APP
// ============================================================

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Riverpod Interview',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UsersScreen(),
    );
  }
}
