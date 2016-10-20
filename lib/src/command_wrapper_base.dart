// Copyright (c) 2016, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:which/which.dart';

/// [CommandResult] contains the information about the result of command
/// execution.
class CommandResult {
  bool get success => exitCode == 0;

  final List<String> stdout;
  final List<String> stderr;
  final int exitCode;

  CommandResult(String stdout, String stderr, this.exitCode)
      : this.stdout = _toLines(stdout),
        this.stderr = _toLines(stderr);
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
      {bool throwOnError: true, String processWorkingDir}) async {
    final executable = await _getExecutable();

    final result = await Process.run(executable, args,
        workingDirectory: processWorkingDir, runInShell: true);

    if (throwOnError) {
      _throwIfProcessFailed(result, executable, args);
    }

    return new CommandResult(result.stdout, result.stderr, result.exitCode);
  }
}

/// A regular expression matching a trailing CR character.
final _trailingCR = new RegExp(r"\r$");

/// Splits [text] on its line breaks in a Windows-line-break-friendly way.
List<String> _splitLines(String text) =>
    text.split("\n").map((line) => line.replaceFirst(_trailingCR, "")).toList();

void _throwIfProcessFailed(
    ProcessResult pr, String process, List<String> args) {
  assert(pr != null);
  if (pr.exitCode != 0) {
    var message = '''
stdout:
${pr.stdout}
stderr:
${pr.stderr}''';

    throw new ProcessException(process, args, message, pr.exitCode);
  }
}

List<String> _toLines(String output) {
  final lines = _splitLines(output);
  if (!lines.isEmpty && lines.last == "") {
    lines.removeLast();
  }
  return lines;
}
