#!/usr/bin/env perl

use Pandoc::Filter;
use Pandoc::Elements;

use Text::VimColor;

# This is to unindent a heredoc below. v5.26 comes with <<~EOF syntax
# to do that but the perl on my target machine is older than that.
sub unindent {
    # First remove confusing newlines, then determine the indentation
    # (of the first line) and remove that from all the lines.
    my $data = shift;
    $data =~ s/^\n+|\n+$//;
	my $indent = $data =~ /^(\s+)/ && $1;
    $data =~ s/^$indent//mg;
    $data
}

pandoc_filter CodeBlock => sub {
    my $block = shift;
    my $filetype = $block->class;
    # Apparently, this won't fail? It produces (non-highlighted) output
    # even if the filetype is not found. I don't know what would happen
    # in more serious cases, though, like vim not being installed.
    my $html = Text::VimColor->new(
        string   => $block->content,
        filetype => $filetype,
    )->html;
    $html =~ s/^\s+|\s+$//; # trim
    return RawBlock html => unindent qq{
        <pre class="synNormal code-$filetype">
        @{[ join "\n", map { "<code>$_</code>" } split "\n", $html ]}
        </pre>
    };
}
