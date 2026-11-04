import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Affiche du texte avec une écriture mathématique propre :
///   \frac{3}{4}   fraction empilée
///   x^{2} ou x^2  exposant          u_{n}  indice
///   \sqrt{16}     racine carrée      \int  ∫   \pi  π   \times  ×
/// Tout le reste s'affiche normalement (emojis, retours à la ligne...).
class MathText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const MathText(this.text, {super.key, this.style, this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    final color = base.color ?? Theme.of(context).colorScheme.onSurface;
    final st = base.copyWith(color: color);
    return Text.rich(
      TextSpan(children: parseMath(text, st)),
      textAlign: textAlign,
    );
  }
}

const _symbols = {
  r'\int': '∫',
  r'\pi': 'π',
  r'\times': '×',
  r'\div': '÷',
  r'\infty': '∞',
  r'\leq': '≤',
  r'\geq': '≥',
  r'\neq': '≠',
  r'\cdot': '·',
  r'\pm': '±',
};

class _Group {
  final String text;
  final int end;
  final bool ok;

  const _Group(this.text, this.end, this.ok);
}

/// Lit un groupe {…} qui commence à l'index [start] (accolades imbriquées).
_Group _group(String s, int start) {
  if (start >= s.length || s[start] != '{') return _Group('', start, false);
  var depth = 0;
  for (var i = start; i < s.length; i++) {
    if (s[i] == '{') depth++;
    if (s[i] == '}') {
      depth--;
      if (depth == 0) return _Group(s.substring(start + 1, i), i + 1, true);
    }
  }
  return _Group('', start, false);
}

/// Transforme le texte en morceaux (texte simple + widgets mathématiques).
List<InlineSpan> parseMath(String s, TextStyle st) {
  final spans = <InlineSpan>[];
  final buf = StringBuffer();
  void flush() {
    if (buf.isNotEmpty) {
      spans.add(TextSpan(text: buf.toString(), style: st));
      buf.clear();
    }
  }

  var i = 0;
  outer:
  while (i < s.length) {
    if (s.startsWith(r'\frac', i)) {
      final a = _group(s, i + 5);
      final b = a.ok ? _group(s, a.end) : a;
      if (a.ok && b.ok) {
        flush();
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _Frac(a.text, b.text, st),
        ));
        i = b.end;
        continue;
      }
    }
    if (s.startsWith(r'\sqrt', i)) {
      final a = _group(s, i + 5);
      if (a.ok) {
        flush();
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _Sqrt(a.text, st),
        ));
        i = a.end;
        continue;
      }
    }
    if (s[i] == '\\') {
      for (final e in _symbols.entries) {
        if (s.startsWith(e.key, i)) {
          buf.write(e.value);
          i += e.key.length;
          continue outer;
        }
      }
    }
    final ch = s[i];
    if ((ch == '^' || ch == '_') && i + 1 < s.length) {
      final g = s[i + 1] == '{' ? _group(s, i + 1) : _Group(s[i + 1], i + 2, true);
      if (g.ok) {
        flush();
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _Script(g.text, st, superscript: ch == '^'),
        ));
        i = g.end;
        continue;
      }
    }
    buf.write(ch);
    i++;
  }
  flush();
  return spans;
}

class _Frac extends StatelessWidget {
  final String num;
  final String den;
  final TextStyle st;

  const _Frac(this.num, this.den, this.st);

  @override
  Widget build(BuildContext context) {
    final fs = st.fontSize ?? 16;
    final small = st.copyWith(fontSize: fs * 0.82, height: 1.1);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fs * 0.12),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(TextSpan(children: parseMath(num, small)), textAlign: TextAlign.center),
            Container(
              height: math.max(1.4, fs * 0.07),
              margin: EdgeInsets.symmetric(vertical: fs * 0.06),
              color: st.color,
            ),
            Text.rich(TextSpan(children: parseMath(den, small)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Sqrt extends StatelessWidget {
  final String arg;
  final TextStyle st;

  const _Sqrt(this.arg, this.st);

  @override
  Widget build(BuildContext context) {
    final fs = st.fontSize ?? 16;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('√', style: st.copyWith(fontSize: fs * 1.1, height: 1.1)),
        Container(
          padding: EdgeInsets.only(top: fs * 0.08, left: fs * 0.05, right: fs * 0.05),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: st.color ?? Colors.black, width: math.max(1.3, fs * 0.065))),
          ),
          child: Text.rich(TextSpan(children: parseMath(arg, st.copyWith(height: 1.1)))),
        ),
      ],
    );
  }
}

class _Script extends StatelessWidget {
  final String text;
  final TextStyle st;
  final bool superscript;

  const _Script(this.text, this.st, {required this.superscript});

  @override
  Widget build(BuildContext context) {
    final fs = st.fontSize ?? 16;
    return Transform.translate(
      offset: Offset(0, superscript ? -fs * 0.42 : fs * 0.28),
      child: Text.rich(
        TextSpan(children: parseMath(text, st.copyWith(fontSize: fs * 0.62, height: 1))),
      ),
    );
  }
}
