#!/usr/bin/env perl

# Clean text copied from tmux before it reaches the clipboard. Called by
# copy-clipboard.sh.
#
#   copy-clean.pl [pane-command] [pane-width] < copied-text
#
# 1. The readable-transcript Claude Code mod draws a ▌ bar beside each line
#    of a reply. On lines that start with it, drop the bar and Claude's ⏺
#    marker, then the indent those lines share (ignoring the mod's timestamp
#    line), so a copied reply pastes as plain text.
#
# 2. Claude Code wraps a reply to the pane width, breaking a row only where
#    the next word won't fit. Rejoin a bar line to the one before it when its
#    first word wouldn't have fitted there, so paragraphs and list items paste
#    as one line each. Breaks Claude meant (short lines, new list items, table
#    rows) stay. A word longer than a row, such as a URL, rejoins with no space.
#
# 3. Only when pane-command is "claude": Claude Code draws a written file as
#    "<n> <code>" rows and an edit as "<n> <+|-| ><code>" rows, and breaks a
#    long line onto rows with no number. Drop the numbers and rejoin broken
#    lines. In an edit, also drop the removed rows and the +/- column, which
#    leaves the code as it now is.

use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));

my $claude = ($ARGV[0] // '') eq 'claude';
my $width = ($ARGV[1] // '') =~ /^\d+$/ ? $ARGV[1] : 0;
my @l = split /\n/, do { local $/; <STDIN> // '' }, -1;

# Each row's width and indent as drawn, before the bar comes off. A first row
# with no bar is a selection that began at the text, 4 columns in.
my @drawn = map { length($_) + (/^▌/ ? 0 : 4) } @l;
my @indent = map { /^(▌ *)/ ? length $1 : 4 } @l;

my @bar = map { $l[$_] =~ s/^▌ ?// } 0 .. $#l;
my @own = grep { $bar[$_] } 0 .. $#l;
if (@own) {
  s/^(\s*)⏺ /$1  / for @l[@own];
  my ($min) = sort { $a <=> $b } map { /^( *)/; length $1 }
    grep { /\S/ && !/^\[\d\d:\d\d:\d\d\] =+$/ } @l[@own];
  if ($min) { s/^ {0,$min}// for @l[@own] }
  rejoin() if $width;
}

@l = strip_numbers() if $claude;
print join "\n", @l;

sub rejoin {
  my (@nl, @nb);
  for my $i (0 .. $#l) {
    my $s = $l[$i];
    if ($i && $bar[$i] && ($bar[$i - 1] || $i == 1) && wrapped($l[$i - 1], $drawn[$i - 1], $s)) {
      $s =~ s/^\s+//;
      my ($tail) = $nl[-1] =~ /(\S+)$/;
      my ($head) = $s =~ /^(\S+)/;
      my $split = $drawn[$i - 1] >= $width && length($tail . $head) > $width - $indent[$i];
      $nl[-1] .= ($split ? '' : ' ') . $s;
      next;
    }
    push @nl, $s;
    push @nb, $bar[$i];
  }
  @l = @nl;
  @bar = @nb;
}

sub wrapped {
  my ($prev, $drawn, $next) = @_;
  return 0 unless $prev =~ /\S/ && $next =~ /\S/;
  return 0 if $prev =~ /^\[\d\d:\d\d:\d\d\] =+$/;
  return 0 if $next =~ /^\s*(?:[-*+•]|\d+[.)])\s/;
  return 0 if $next =~ /^\s*[│├└┌╭╰|]/ || $prev =~ /[│┤┐┘╮╯|]\s*$/;
  my ($word) = $next =~ /^\s*(\S+)/;
  return $drawn + 1 + length($word) > $width;
}

# Group numbered rows, and the unnumbered rows that continue them, into
# blocks, and hand each block to render. Bar lines are prose, never code.
sub strip_numbers {
  my (@out, @blk, $col);
  for my $i (0 .. $#l) {
    my $s = $l[$i];
    # The first row may start mid-gutter; later ones come from the left edge.
    my $lead = $i == 0 ? 0 : 2;
    if (!$bar[$i] && $s =~ /^( {$lead,})(\d+)(?: (.*))?$/) {
      $col = length($1) + length($2) + 1;
      push @blk, { raw => $s, n => $2, lead => length $1, rest => $3 // '' };
    } elsif (@blk && !$bar[$i] && $s =~ /^ {$col}(.*)$/) {
      push @blk, { raw => $s, cont => 1, rest => $1 };
    } else {
      push @out, render(@blk), $s;
      @blk = ();
    }
  }
  return (@out, render(@blk));
}

sub render {
  my @b = @_;
  my @num = grep { !$_->{cont} } @b;
  my @raw = map { $_->{raw} } @b;
  return @raw unless @num;

  my ($diff, $drop);
  if (@num == 1) {
    # A lone row, such as a triple-click: only a full row with code after the
    # number, so output like "  42 files" isn't touched. Keep it even if removed.
    return @raw unless $num[0]{lead} >= 6 && $num[0]{rest} ne '';
    $diff = $num[0]{rest} =~ /^[+-]/;
  } else {
    # An edit repeats a number where it removes a line, or adds lines. A file
    # preview counts up by one, which tells it apart from other numbered output.
    my $marked = !grep { $_->{rest} ne '' && $_->{rest} !~ /^[ +-]/ } @num;
    my $dup = grep { $num[$_]{n} == $num[$_ - 1]{n} } 1 .. $#num;
    my $plus = grep { $_->{rest} =~ /^\+/ } @num;
    $diff = $drop = $marked && ($dup || $plus);
    return @raw if !$diff && grep { $num[$_]{n} != $num[$_ - 1]{n} + 1 } 1 .. $#num;
  }

  my @out;
  for my $e (@b) {
    my $code = $e->{rest};
    if ($diff) {
      my $mark = substr $code, 0, 1, '';
      next if $drop && $mark eq '-';
    }
    if ($e->{cont} && @out) { $out[-1] .= $code } else { push @out, $code }
  }
  return @out;
}
