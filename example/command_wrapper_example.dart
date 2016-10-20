// Copyright (c) 2016, Kwang Yul Seo. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

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

