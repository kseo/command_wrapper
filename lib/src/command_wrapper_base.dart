// Copyright (c) 2016, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:which/which.dart';

/// [CommandResult] contains the information about the result of command
/// execution.
class CommandResult {
  bool get success => exitCode == 0;

  final List<String> stdout;
  final List<String> stderr;
  final int exitCode;

  CommandResult(this.stdout, this.stderr, this.exitCode);
}

/// [CommandWrapper] runs the executable as a separate process and returns
/// the result in [CommandResult].
class CommandWrapper {
  final String binName;

  String _executableCache;

  /// Creates a [CommandWrapper] instance with the given [binName].
  ///
  /// It locates the executable using `which` package.
  CommandWrapper(this.binName);

  Future<String> _getExecutable() async {
    if (_executableCache == null) {
      _executableCache = await which(binName);
    }
    return _executableCache;
  }

  /// Runs the command with teh given [args].
  ///
  /// Throws a [ProcessException] if [throwsOnError] is true and exitCode is
  /// not 0.
  Future<CommandResult> run(List<String> args,
      {bool throwOnError: true,
      String processWorkingDir,
      List<String> stdin}) async {
    final executable = await _getExecutable();

    final process = await Process.start(executable, args,
        workingDirectory: processWorkingDir, runInShell: true);
    if (stdin != null) {
      for (final line in stdin) {
        process.stdin.writeln(line);
      }
      process.stdin.close();
    }
    List<String> stdout = [];
    List<String> stderr = [];
    process.stdout
        .transform(UTF8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      stdout.add(line);
    });
    process.stderr
        .transform(UTF8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      stderr.add(line);
    });

    final exitCode = await process.exitCode;
    if (throwOnError) {
      _throwIfProcessFailed(executable, exitCode, stdout, stderr, args);
    }

    return new CommandResult(stdout, stderr, exitCode);
  }
}

void _throwIfProcessFailed(String executable, int exitCode, List<String> stdout,
    List<String> stderr, List<String> args) {
  if (exitCode != 0) {
    var message = '''
stdout:
${stdout.join('\n')}
stderr:
${stderr.join('\n')}''';

    throw new ProcessException(executable, args, message, exitCode);
  }
}
