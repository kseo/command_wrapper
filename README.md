# command_wrapper

command_wrapper package makes it easy to create a Dart wrapper for command line tools.

## Usage

`CommandWrapper` lets you create a Dart wrapper for command line tools. For
example, you can create a wrapper for `curl` by passing the executable name to
the `CommandWrapper` constructor. The path of `curl` is autmatically located in a
platform independent manner using [which][which] package.

[which]: https://pub.dartlang.org/packages/which

```dart
CommandWrapper curl = new CommandWrapper('curl');
CommandResult result = await curl.run(['--version']);
```

`CommandResult` contains `stdout`, `stderr` and `exitCode`. The type of `stdout`
and `stderr` is `List<String>` so you can easily process each line.

## Command

command_wrapper provides wrappers for commonly used Dart commands.

* dart
* pub
* dart2js
* dartfmt
* dartanalyzer
* dartdoc

## Examples

```dart
import 'package:command_wrapper/command_wrapper.dart';

main() async {
  // Use dart CommandWrapper instance.
  CommandResult result = await dart.run(['--version']);
  print(result.stderr.join(''));

  // Create a new CommandWrapper.
  CommandWrapper curl = new CommandWrapper('curl');
  result = await curl.run(['--version']);
  print(result.stdout.join(''));
}
```

