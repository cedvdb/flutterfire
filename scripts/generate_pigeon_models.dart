// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// Extracts the data classes Pigeon generates into the Flutter free
/// `*_common` packages, and rewrites the generated files so that they import
/// (and re-export) those classes.
///
/// Pigeon data classes are pure Dart; only the host APIs, the message codec
/// and the `PlatformException` helpers emitted in the same file depend on
/// Flutter. Extracting the data classes is what allows platform
/// implementations (such as the `*_web` packages) and their platform
/// interfaces to be consumed outside of Flutter.
///
/// This script is meant to be run right after Pigeon, which is what
/// `melos run generate:pigeon` does. It fails when a generated file was
/// already split, so that the data classes are always extracted from the
/// output of Pigeon itself.
void main(List<String> args) {
  final root = Directory.current;
  final failures = <String>[];
  final targets = args.isEmpty
      ? _targets
      : _targets.where((target) => args.any(target.generated.contains));

  for (final target in targets) {
    try {
      _split(root, target);
      stdout.writeln('Extracted ${target.models}.');
    } on _SplitError catch (error) {
      failures.add('${target.generated}: ${error.message}');
    }
  }

  if (failures.isNotEmpty) {
    stderr
      ..writeln('Failed to extract the Pigeon data classes:')
      ..writeln(failures.map((failure) => '  - $failure').join('\n'));
    exit(1);
  }
}

class _Target {
  const _Target({
    required this.generated,
    required this.models,
    required this.packageImport,
  });

  /// The Pigeon generated Dart file, relative to the repository root.
  final String generated;

  /// Where the data classes are extracted to, relative to the repository root.
  final String models;

  /// The import the generated file uses to access the extracted data classes.
  final String packageImport;
}

const List<_Target> _targets = <_Target>[
  _Target(
    generated: 'packages/firebase_core/firebase_core_platform_interface'
        '/lib/src/pigeon/messages.pigeon.dart',
    models: 'packages/firebase_core/firebase_core_common'
        '/lib/src/pigeon/messages.dart',
    packageImport: 'package:firebase_core_common/src/pigeon/messages.dart',
  ),
  _Target(
    generated: 'packages/firebase_auth/firebase_auth_platform_interface'
        '/lib/src/pigeon/messages.pigeon.dart',
    models: 'packages/firebase_auth/firebase_auth_common'
        '/lib/src/pigeon/messages.dart',
    packageImport: 'package:firebase_auth_common/src/pigeon/messages.dart',
  ),
];

/// The first declaration of the Flutter dependent part of Pigeon's output.
const String _codecMarker = 'class _PigeonCodec extends StandardMessageCodec {';

/// Symbols which must never appear in the extracted data classes: they all
/// come from libraries which depend on Flutter.
const List<String> _flutterSymbols = <String>[
  'flutter/services.dart',
  'flutter/foundation.dart',
  'PlatformException',
  'ReadBuffer',
  'WriteBuffer',
  'StandardMessageCodec',
  'MethodChannel',
  'BinaryMessenger',
];

File _file(Directory root, String path) => File('${root.path}/$path');

class _SplitError implements Exception {
  _SplitError(this.message);

  final String message;
}

void _split(Directory root, _Target target) {
  final generatedFile = _file(root, target.generated);
  final modelsFile = _file(root, target.models);
  final source = generatedFile.readAsStringSync();
  final import = "import '${target.packageImport}';";

  if (source.contains(import)) {
    throw _SplitError(
      'already split; run Pigeon again so that the generated file is '
      'recreated before the data classes are extracted.',
    );
  }

  final lines = source.split('\n');
  final codecIndex = lines.indexOf(_codecMarker);

  if (codecIndex == -1) {
    throw _SplitError('`$_codecMarker` was not found.');
  }

  final importsEnd = lines.lastIndexWhere(
    (line) => line.startsWith('import '),
    codecIndex,
  );

  if (importsEnd == -1) {
    throw _SplitError('no import directive was found.');
  }

  final declarations = _declarations(lines, importsEnd + 1, codecIndex);
  final modelsStart = declarations.indexWhere((it) => it.isTypeDeclaration);

  if (modelsStart == -1) {
    throw _SplitError('no data class was found.');
  }

  final models = declarations.sublist(modelsStart);

  for (final declaration in models) {
    if (!declaration.isTypeDeclaration) {
      throw _SplitError(
        'unexpected declaration in front of the message codec: '
        '`${declaration.name}`.',
      );
    }
  }

  // Helpers shared with the data classes (deep equality and hashing) move with
  // them, the `PlatformException` based helpers stay behind.
  final modelsText = models.map((it) => it.text).join('\n\n');
  final helpers = <_Declaration>[];

  for (final candidate in declarations.sublist(0, modelsStart)) {
    final isUsed = !candidate.isTypeDeclaration &&
        <String>[
          modelsText,
          ...helpers.map((it) => it.text),
        ].any(candidate.isReferencedIn);

    if (isUsed) {
      helpers.add(candidate);
    }
  }

  final moved = <_Declaration>[...helpers, ...models];
  final movedText = <String>[
    ...helpers.map((it) => it.text),
    modelsText,
  ].join('\n\n');

  for (final symbol in _flutterSymbols) {
    if (movedText.contains(symbol)) {
      throw _SplitError(
        'the data classes depend on `$symbol`, which is not available outside '
        'of Flutter.',
      );
    }
  }

  for (final declaration in declarations) {
    final name = declaration.name;

    if (name == null || moved.contains(declaration)) {
      continue;
    }

    if (RegExp('\\b$name\\b').hasMatch(movedText)) {
      throw _SplitError(
        '`$name` moved with the data classes while the generated file still '
        'uses it.',
      );
    }
  }

  // The line following a moved declaration is dropped as well, so that
  // removing it does not leave two empty lines behind.
  final dropped = <int>{};
  for (final declaration in moved) {
    for (var line = declaration.start; line <= declaration.end + 1; line++) {
      dropped.add(line);
    }
  }

  final generated = <String>[
    ...lines.sublist(0, importsEnd + 1),
    import,
    "export '${target.packageImport}';",
    '',
  ];

  for (var index = importsEnd + 1; index < lines.length; index++) {
    if (!dropped.contains(index)) {
      generated.add(lines[index]);
    }
  }

  final headerLines = lines.sublist(
    0,
    lines.indexWhere((line) => line.startsWith('import ')),
  );
  final notice = <String>[
    '//',
    '// The data classes below are extracted into this package from',
    '// `${target.generated}`',
    '// by `scripts/generate_pigeon_models.dart`, so that they can be used',
    '// without a Flutter dependency.',
  ];
  final seeAlso = headerLines.indexWhere(
    (line) => line.startsWith('// See also:'),
  );

  headerLines.insertAll(
    seeAlso == -1 ? headerLines.length : seeAlso + 1,
    notice,
  );

  final modelsSource = <String>[
    ..._collapseEmptyLines(headerLines),
    '',
    ..._importsFor(movedText),
    '',
    movedText,
  ];

  modelsFile
    ..createSync(recursive: true)
    ..writeAsStringSync(
      '${_collapseEmptyLines(modelsSource).join('\n').trimRight()}\n',
    );

  generatedFile.writeAsStringSync(
    '${_collapseEmptyLines(generated).join('\n').trimRight()}\n',
  );
}

/// Collapses consecutive empty lines, which `dart format` would otherwise
/// remove.
List<String> _collapseEmptyLines(List<String> lines) {
  final collapsed = <String>[];

  for (final line in lines) {
    if (line.trim().isEmpty &&
        (collapsed.lastOrNull?.trim().isEmpty ?? false)) {
      continue;
    }

    collapsed.add(line);
  }

  return collapsed;
}

/// The imports needed by the extracted data classes.
List<String> _importsFor(String text) {
  final imports = <String>[];

  if (RegExp(r'\b(Float64List|Int32List|Int64List|Uint8List|ByteData)\b')
      .hasMatch(text)) {
    imports.add("import 'dart:typed_data';");
  }

  if (RegExp('@(immutable|protected|visibleForTesting)').hasMatch(text)) {
    imports.add("import 'package:meta/meta.dart';");
  }

  return imports;
}

extension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}

/// Splits the top level declarations of [lines] between [start] (inclusive)
/// and [end] (exclusive).
///
/// A declaration ends on a line which only contains a closing brace, which is
/// how `dart format` writes top level declarations.
List<_Declaration> _declarations(List<String> lines, int start, int end) {
  final declarations = <_Declaration>[];
  var index = start;

  while (index < end) {
    if (lines[index].trim().isEmpty) {
      index++;
      continue;
    }

    // Documentation in front of a declaration belongs to that declaration.
    final declarationStart = index;

    while (index < end &&
        (lines[index].trim().isEmpty ||
            lines[index].trimLeft().startsWith('//'))) {
      index++;
    }

    if (index >= end) {
      break;
    }

    var codeStart = index;

    // Annotations are not part of the code that identifies the declaration.
    while (codeStart < end && lines[codeStart].startsWith('@')) {
      codeStart++;
    }

    if (codeStart >= end) {
      break;
    }

    var declarationEnd = codeStart;

    while (declarationEnd < end && lines[declarationEnd] != '}') {
      declarationEnd++;
    }

    if (declarationEnd >= end) {
      throw _SplitError('unterminated declaration at line ${codeStart + 1}.');
    }

    declarations.add(
      _Declaration(
        start: declarationStart,
        end: declarationEnd,
        code: lines.sublist(codeStart, declarationEnd + 1).join('\n'),
        text: lines.sublist(declarationStart, declarationEnd + 1).join('\n'),
      ),
    );

    index = declarationEnd + 1;
  }

  return declarations;
}

class _Declaration {
  const _Declaration({
    required this.start,
    required this.end,
    required this.code,
    required this.text,
  });

  /// The line the declaration, including its documentation, starts on.
  final int start;

  /// The line the declaration ends on.
  final int end;

  /// The declaration without its documentation.
  final String code;

  /// The declaration including its documentation.
  final String text;

  bool get isTypeDeclaration => RegExp(
        '^(?:abstract |sealed |base |final )*(?:class|enum|mixin) ',
      ).hasMatch(code.trimLeft());

  /// The name of the declaration, `null` when it cannot be determined.
  String? get name {
    final type = RegExp(
      r'^(?:abstract |sealed |base |final )*(?:class|enum|mixin)\s+(\w+)',
    ).firstMatch(code.trimLeft());

    if (type != null) {
      return type.group(1);
    }

    return RegExp(r'(\w+)\s*\(').firstMatch(code)?.group(1);
  }

  /// Whether [text] references the declaration.
  bool isReferencedIn(String text) {
    final declarationName = name;

    if (declarationName == null) {
      return false;
    }

    return RegExp('\\b$declarationName\\b').hasMatch(text);
  }
}
