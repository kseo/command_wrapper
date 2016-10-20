# command_wrapper

Make it easy to create a Dart wrapper for command line tools.

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
