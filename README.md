# advent-html

Quick and dirty script to convert Markdown to HTML with syntax
highlighting of exotic languages (such as Perl 6), powered by
pandoc and vim syntax files.

## SYNOPSIS

```
$ ./advent-html.sh --standalone example/001.md | tee 001.html
[WARNING] This document format requires a nonempty <title> element.
  Please specify either 'title' or 'pagetitle' in the metadata.
  Falling back to '001'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="" xml:lang="">
<head>
  <meta charset="utf-8" />
  <meta name="generator" content="pandoc" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />
  <title>001</title>
  <style type="text/css">
      code{white-space: pre-wrap;}
      span.smallcaps{font-variant: small-caps;}
      span.underline{text-decoration: underline;}
      div.column{display: inline-block; vertical-align: top; width: 50%;}
  </style>
  <link rel="stylesheet" href="highlight.css" />
  <!--[if lt IE 9]>
    <script src="//cdnjs.cloudflare.com/ajax/libs/html5shiv/3.7.3/html5shiv-printshiv.min.js"></script>
  <![endif]-->
</head>
<body>
<h1 id="this-is-a-test">This is a test</h1>
<p>Some <code>Perl 6</code> code:</p>
<pre class="synNormal code-perl6">
<code><span class="synComment"># This isn't meant to make sense but use a lot of syntax.</span></code>
<code><span class="synStatement">sub</span> fx (<span class="synIdentifier">$bytes</span><span class="synStatement">,</span> <span class="synIdentifier">$chunking</span><span class="synStatement">?</span> <span class="synPreProc">where</span> <span class="synStatement">*.</span>so) {</code>
<code>    react whenever <span class="synIdentifier">$bytes</span> <span class="synStatement">-&gt;</span> <span class="synStatement">*</span><span class="synIdentifier">@chunk</span> {</code>
<code>        <span class="synStatement">gather</span> print <span class="synStatement">.</span>format(<span class="synSpecial">&quot;</span><span class="synConstant">%02x</span><span class="synSpecial">&quot;</span>)</code>
<code>          <span class="synStatement">for</span> <span class="synIdentifier">@chunk</span><span class="synStatement">».</span>map(<span class="synStatement">*.</span><span class="synType">Int</span> <span class="synPreProc">but</span> <span class="synType">False</span>)</code>
<code>          <span class="synStatement">andthen</span> <span class="synStatement">.</span>take<span class="synStatement">;</span></code>
<code>        say <span class="synStatement">++</span><span class="synIdentifier">$</span><span class="synStatement">,</span> <span class="synStatement">...</span></code>
<code>        <span class="synComment"># </span><span class="synTodo">FIXME</span><span class="synComment">: does this highlight?</span></code>
<code>    }</code>
<code>}</code>
</pre>
</body>
</html>
```

## DEPENDENCIES

It uses `pandoc` to convert the input document (I use Markdown) to
HTML. Syntax highlighting is done via ``Text::VimColor`` in conjunction
with the `Pandoc::Filter` and `Pandoc::Elements` modules from CPAN.

For any language that must be highlighted, `vim` needs to have a
corresponding syntax file available. To install perl6 syntax files,
refer to <https://github.com/vim-perl/vim-perl6>. See `examples`
for a file which uses syntax highlighting.

A script `vim2css.pl` for converting vim color schemes to CSS files
is included.
