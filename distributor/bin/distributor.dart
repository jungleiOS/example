import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

const String version = '0.0.1';

const lineNumber = 'line-number';

void main(List<String> arguments) {
  exitCode = 0;
  final parser = ArgParser()..addFlag(lineNumber, negatable: false, abbr: 'n');

  final argResults = parser.parse(arguments);
  final paths = argResults.rest;
  dcat(paths, showLineNumbers: argResults[lineNumber] as bool);
}

Future<void> dcat(List<String> paths, {bool showLineNumbers = false}) async {
  if (paths.isEmpty) {
    await stdin.pipe(stdout);
  } else {
    for (final path in paths) {
      var lineNumber = 1;
      final lines = utf8.decoder
          .bind(File(path).openRead())
          .transform(const LineSplitter());
      try {
        await for (final line in lines) {
          if (showLineNumbers) {
            stdout.write('${lineNumber++}. ');
          }
          stdout.writeln(line);
        }
      } catch (_) {
        await _handleError(path);
      }
    }
  }
}

Future<void> _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('error: $path is directory');
  } else {
    exitCode = 2;
  }
}

class Config {
  final String projectName;
  final String workingDirectory;
  final String buildCommand;
  final String pgyKey;

  Config({
    this.projectName = '',
    this.workingDirectory = '',
    this.buildCommand = '',
    this.pgyKey = '',
  });

  Config.fromJson(Map<String, dynamic> json)
      : projectName = json['projectName'] as String,
        workingDirectory = json['workingDirectory'] as String,
        buildCommand = json['buildCommand'] as String,
        pgyKey = json['pgyKey'] as String;

  Map<String, dynamic> toJson() => {
        'projectName': projectName,
        'workingDirectory': workingDirectory,
        'buildCommand': buildCommand,
        'pgyKey': pgyKey,
      };
}

// late String projectName = '';
// late String workingDirectory = '';
// late String buildCommand = '';
// late String pgyKey = '';

class StreamTest {
  static Future<int> sumStream(Stream<int> stream) async {
    var sum = 0;
    await for (var value in stream) {
      sum += value;
    }
    return sum;
  }

  static Stream<int> buildStream(int count) async* {
    for (var i = 0; i < count; i++) {
      yield i;
    }
  }

  static void transformerDemo() {
    final controller = StreamController<int>();
    final transformer = StreamTransformer<int, String>.fromHandlers(
      handleData: (data, sink) {
        if (data == 100) {
          sink.add('yes');
        } else {
          sink.add('no');
        }
      },
    );
    controller.stream.transform(transformer).listen(
      (event) {
        print(event);
      },
      onDone: () => print('done'),
      onError: (err) => print(err),
    );
    controller.add(23);
    controller.add(100);
    controller.add(99);
  }
}
