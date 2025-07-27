import 'dart:io';

import 'package:flutter/material.dart';
import 'package:online_image_classification/controller/home_provider.dart';
import 'package:online_image_classification/service/http_service.dart';
import 'package:online_image_classification/util/widgets_extension.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeProvider(HttpService()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Classification", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  @override
  void initState() {
    super.initState();

    final homeProvider = context.read<HomeProvider>();

    homeProvider.addListener(() {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final message = homeProvider.message;

      if (message != null) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 4,
            children: [
              Expanded(
                child: Consumer<HomeProvider>(
                  builder: (context, value, child) {
                    final imagePath = value.imagePath;
                    return imagePath == null
                        ? const Align(
                            alignment: Alignment.center,
                            child: Icon(Icons.image, size: 100),
                          )
                        : Image.file(
                            File(imagePath.toString()),
                            fit: BoxFit.contain,
                          );
                  },
                ),
              ),
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Consumer<HomeProvider>(
                    builder: (context, value, child) {
                      final uploadResponse = value.uploadResponse;
                      final data = uploadResponse?.data;
                      if (value.uploadResponse == null || data == null) {
                        return SizedBox.shrink();
                      }

                      return Text(
                        "${data?.result} - ${data?.confifenceScore.round()}%",
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  Row(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            context.read<HomeProvider>().openGallery(),
                        child: const Text("Gallery"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<HomeProvider>().openCamera(),
                        child: const Text("Camera"),
                      ),
                      ElevatedButton(
                        onPressed: () => context
                            .read<HomeProvider>()
                            .openCustomCamera(context),
                        child: const Text(
                          "Custom Camera",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ].expanded(),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.read<HomeProvider>().upload(),
                    child: Consumer<HomeProvider>(
                      builder: (context, value, child) {
                        if (value.isUploading) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return const Text("Analyze");
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
