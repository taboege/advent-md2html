#!/usr/bin/env perl

# Walk through a vim color file and try to make a CSS file out of it.
# We just guess what it does using regular expressions.

use Modern::Perl;
use FindBin;
use utf8;

# Which configuration keys to look at "term" or "gui" ones.
#use constant FOREGROUND_PREF  => 'ctermfg';
#use constant BACKGROUND_PREF  => 'ctermbg';
use constant FOREGROUND_PREF  => 'guifg';
use constant BACKGROUND_PREF  => 'guibg';
use constant ATTRIBUTE_PREF   => 'gui';

# What "dark" and "light" background means
use constant BACKGROUND_DARK  => '#404040';
use constant BACKGROUND_LIGHT => '#d0d0d0';
# And corresponding foregrounds
use constant FOREGROUND_DARK  => '#000000';
use constant FOREGROUND_LIGHT => '#d0d0d0';

sub read_definition {
    no warnings qw(uninitialized);
    my ($fg, $bg, $attr);

    while (/(\S+)=(\S+)/g) {
        my ($key, $value) = ($1, $2);
        # Try to honor *_PREF settings but fall back to alternatives.
        if ($key =~ /^(gui|c?term)$/) {
            next unless not $attr or $key eq ATTRIBUTE_PREF;
            $attr = $value if $value eq 'bold'; # not doing the other shenanigans
        }
        elsif ($key =~ /fg$/) {
            next unless !defined($fg) or $key eq FOREGROUND_PREF;
            $fg = $value;
        }
        elsif ($key =~ /bg$/) {
            next unless not $bg or $key eq BACKGROUND_PREF;
            $bg = $value;
        }
    }
    # Try to resolve references
    $fg = $bg if $fg eq "bg";
    $bg = $fg if $bg eq "fg";
    $fg = "" if lc $fg eq "none";
    $bg = "" if lc $bg eq "none";
    return ($fg // '', $bg // '', $attr // '');
}

my $filename = $ARGV[0] // '<stdin>';

# Read color definitions
use Color::Rgb;
# Apparently vim echoes on stderr
my $vimpath = `vim -RXZNn --not-a-term -i NONE -u NONE --cmd 'echon \$VIMRUNTIME|q' 2>&1 >&-`;
$vimpath =~ s/(\r?\n)*$//;
my $colors = new Color::Rgb(rgb_txt => "$vimpath/rgb.txt");

sub get_rgb {
    my @TERM_COLORS = (
        'black',
        'darkred',
        'darkgreen',
        'brown',
        'darkblue',
        'darkmagenta',
        'darkcyan',
        'lightgray',
        'darkgray',
        'lightred',
        'lightgreen',
        'yellow',
        'lightblue',
        'lightmagenta',
        'lightcyan',
        'white',
    );
    local $_ = shift;
    # already is #RRGGBB color
    return $_ if m/^#/;
    # Terminal color number
    $_ = $TERM_COLORS[$_] if m/^\d+$/;
    # Probably color name
    return $colors->hex($_, "#");
}

# Read the color scheme
my ($foreground, $background);
my %category;
while (<>) {
    if (/set background=(dark|light)/) {
        $background = $1;
    }
    elsif (/hi link\s+(\S+)\s+(\S+)$/) {
        my ($from, $to) = ($1, $2);
        $category{$from} = $to;
    }
    elsif (/hi (\S+)\s+(.*)$/) {
        my $key = $1;
        my ($fg, $bg, $attr) = read_definition $2;
        eval {
            $fg = get_rgb $fg if $fg;
            $bg = get_rgb $bg if $bg;
        };
        if ($@) {
            warn "Ignoring $key. Don't understand the syntax: $@";
            next;
        }
        $category{$key} = [$fg, $bg, $attr];
    }
}

sub print_style {
    my ($cat, $class) = @_;
    $class //= ".syn" . ucfirst $cat;
    my $v = $category{$cat};
    $v = $category{$v} until ref($v) eq 'ARRAY'; # lookup "hi link"
    my ($fg, $bg, $attr) = @$v;
    print "$class {";
    print " color: $fg;" if $fg;
    print " background-color: $bg;" if $bg;
    if ($attr eq "bold") {
        print " font-weight: bold;";
    } # others TBD
    say " }"
}

say "/* This theme was generated from $filename by @{[ $FindBin::Script ]} */";
unless (defined $category{Normal}) {
    # Stub a Normal style
    ($foreground, $background) = $background eq "dark" ?
        (FOREGROUND_LIGHT, BACKGROUND_DARK) :
        (FOREGROUND_DARK, BACKGROUND_LIGHT)
    ;
    say ".synNormal { color: $foreground; background-color: $background; }";
}
# TODO: Only echo what is relevant for syntax highlighting,
# not stuff like DiffAdd, VertSplit, Search, ...
# The relevant categories are documented in Text::VimColor.
print_style $_ for keys %category;

print "/* Line numbers */";
print qq[
.synNormal:before { counter-reset: synLineNo; }
.synNormal code { counter-increment: synLineNo; }
.synNormal code::before { content: counter(synLineNo); display: inline-block;
  width: 4em; text-align: center; border-right: 1px solid; margin-right: 1em; }
];
# Some color themes do specify line number style.
# Just repeat that again. FIXME: don't duplicate styles.
# Can be solved by the TODO above about just echoing
# the syntax-relevant categories.
print_style 'LineNr', ".synNormal code::before" if defined $category{LineNr};

say "/* Border */";
print ".synNormal { border: 1px dashed";
if (defined $category{LineNr}) {
    my ($fg,) = @{$category{LineNr}};
    print " $fg";
}
say "; }";

say "/* Box itself */";
say ".synNormal { max-width: 70%; overflow: auto; margin: 0 auto; }";
