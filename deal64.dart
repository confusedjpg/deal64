// some argument experiments
// encoding/decoding text
// the algorithm is named DEAL64 (Dan's Encoding ALgorithm, 64 security researchers will laugh at you)

// default action will be:
// encode the input, only once, and output

import 'dart:math';

void main(List<String> argv) {
  Map data = parseArgs(argv, PARAMETERS);

  //print(data);
  int passes = int.tryParse(data['passes']) ?? 1;
  String encodeInput = data['encode'], decodeInput = data['decode'];
  if (data['encode'].isNotEmpty) {
    for (int i = 0; i < passes; i++) {
      encodeInput = encode(encodeInput);
    }
    print("ENCODED: '$encodeInput'");
  }

  if (data['decode'].isNotEmpty) {
    for (int i = 0; i < passes; i++) {
      decodeInput = decode(decodeInput);
    }
    print("DECODED: '$decodeInput'");
  }
}

const ALPHA = "abcdefghijklmnopqrstuvwxyz0123456789 ";
const keyTooLongDelimiter = "[&1]", inputTooLongDelimiter = "[&2]";

List<String> rot13(String input, {int amount = 13}) {
  final buffer = StringBuffer();
  final unknown = StringBuffer();
  for (String char in input.split('')) {
    if (ALPHA.contains(char)) {
      buffer.write(ALPHA[(ALPHA.indexOf(char) + amount) % ALPHA.length]);
    } else {
      buffer.write(char);
      unknown.write(char);
    }
  }

  return [buffer.toString(), unknown.toString()];
}

String shuffleString(String input) {
  final list = input.split('');
  list.shuffle();
  return list.join();
}

String encode(String input) {
  var data = rot13(input);
  input = data[0];
  final key = shuffleString(ALPHA + data[1]);
  final byte = key.length.toString().length;
  final buffer = StringBuffer(byte);

  final tmp = StringBuffer();
  for (final char in input.split('')) {
    tmp.write(key.indexOf(char).toString().padLeft(byte));
  }
  final indexed = tmp.toString();

  int minLength = min(indexed.length, key.length);
  for (int i = 0; i < minLength; i++) {
    buffer
      ..write(indexed[i])
      ..write(key[i]);
  }
  if (minLength == indexed.length) {
    buffer
      ..write(keyTooLongDelimiter)
      ..write(key.substring(minLength));
  } else {
    buffer
      ..write(inputTooLongDelimiter)
      ..write(indexed.substring(minLength));
  }

  return buffer.toString().split('').reversed.join();
}

String decode(String input) {
  input = input.split('').reversed.join();
  if (!input.contains(keyTooLongDelimiter) &&
      !input.contains(inputTooLongDelimiter)) {
    print("INFO: this doesn't seem like an encoded message, returned input.");
    return input;
  }

  final byte =
      int.parse(input[0]); // assuming we won't go past a length of 9 digits..
  input = input.substring(1);

  final keyBuffer = StringBuffer();
  final indexedBuffer = StringBuffer();
  final keyTooLong = input.contains(keyTooLongDelimiter);

  int delimiterIndex = keyTooLong
      ? input.indexOf(keyTooLongDelimiter)
      : input.indexOf(inputTooLongDelimiter);

  for (int i = 0; i < delimiterIndex; i += 2) {
    indexedBuffer.write(input[i]);
    keyBuffer.write(input[i + 1]);
  }

  if (keyTooLong) {
    keyBuffer.write(input.split(keyTooLongDelimiter)[1]);
  } else {
    indexedBuffer.write(input.split(inputTooLongDelimiter)[1]);
  }

  final key = keyBuffer.toString(), indexed = indexedBuffer.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < indexed.length; i += byte) {
    int index = int.parse(indexed.substring(i, i + byte));
    buffer.write(key[index]);
  }

  return rot13(buffer.toString(), amount: -13)[0];
}

class Parameter {
  String? long, description;
  String short;
  int requiredArgs;
  bool required;
  Function? action;

  Parameter({
    required this.short,
    required this.required,
    required this.requiredArgs,
    required this.description,
    this.long,
  });
}

final List<Parameter> PARAMETERS = [
  Parameter(
    short: 'e',
    required: false,
    requiredArgs: 1,
    description: "encode given input as DEAL.",
    long: 'encode',
  ),
  Parameter(
    short: 'd',
    required: false,
    requiredArgs: 1,
    description:
        "decode given input back from DEAL (returns the input if it's not considered encoded)",
    long: 'decode',
  ),
  Parameter(
    short: 'p',
    required: false,
    requiredArgs: 1,
    description:
        "how many passes to do (WARNING: the output gets big very quick)",
    long: 'passes',
  ),
  Parameter(
    short: 'h',
    required: false,
    requiredArgs: 0,
    description: "shows this help page",
    long: 'help',
  ),
  Parameter(
    short: 'a',
    required: false,
    requiredArgs: 0,
    description: "get info about the script",
    long: 'about',
  ),
];

// args:
// - how many passes
// - encoding/decoding

void helpPrint(List<Parameter> parameters) {
  print("Usage: deal64 [OPTION...]");
  for (final parameter in parameters) {
    String long = parameter.long == null ? "" : "--${parameter.long}";
    print("\t-${parameter.short}, $long \t ${parameter.description}");
  }
}

Map parseArgs(List<String> argv, List<Parameter> parameters) {
  Map data = {
    'encode':
        argv.isNotEmpty && argv.indexWhere((elem) => elem.startsWith('-')) == -1
            ? argv[0]
            : '',
    'decode': '',
    'passes': '1',
  };

  if (argv.isEmpty || argv.contains('-h') || argv.contains('--help')) {
    helpPrint(parameters);
    return data;
  }

  if (argv.contains('-a') || argv.contains('--about')) {
    print("""
    tiny "encoding" algorithm written in Dart.
    it's called DEAL64 because it's: "Dan's Encoding ALgorithm, 64 security researchers will laugh at you"
    i call it encoding, there's no way this will encrypt anything reliably and securely""");
  }

  for (final parameter in parameters) {
    if (argv.contains("-${parameter.short}") ||
        argv.contains("--${parameter.long}")) {
      if (parameter.requiredArgs > 0) {
        int index = argv.contains("-${parameter.short}")
            ? argv.indexOf("-${parameter.short}")
            : argv.indexOf("--${parameter.long}");
        List<String> args = argv.sublist(index + 1); // this hurts my eyes
        if (args.indexWhere((elem) => elem.startsWith('-')) > -1) {
          args =
              args.sublist(0, args.indexWhere((elem) => elem.startsWith("-")));
        }
        //print(args);
        if (args.length < parameter.requiredArgs) {
          helpPrint(parameters);
          return data;
        }
        for (final arg in args) {
          if (parameter.requiredArgs == 1) {
            data[parameter.long] = arg;
          } else {
            data[parameter.long].add(arg);
          }
        }
      }
    }
  }

  return data;
}
