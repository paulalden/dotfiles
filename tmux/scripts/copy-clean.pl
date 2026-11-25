#!/usr/bin/env perl

# Clean text copied from tmux before it reaches the clipboard. Called by
# copy-clipboard.sh.
#
#   copy-clean.pl [pane-command] [pane-width] < copied-text
#
# 1. The readable-transcript Claude Code mod draws a │ bar beside each line
#    of a reply and of your own messages, and a └──── line under each, a
#    reply's carrying the time (older versions drew the bar as ▌, kept your
#    ❯, and put the time in a line of its own). On lines
#    that start with the bar, drop it and Claude's ⏺ or an old ❯, then the
#    indent those lines share (ignoring an old timestamp line), and drop the
#    border lines, so a copied reply pastes as plain text.
#
# 2. Only when pane-command is "claude": Claude Code draws a written file as
#    "<n> <code>" rows and an edit as "<n> <+|-| ><code>" rows, and breaks a
#    long line onto rows with no number. Drop the numbers and rejoin broken
#    lines. In an edit, also drop the removed rows and the +/- column, which
#    leaves the code as it now is.
#
# 3. Only when pane-command is "claude": other text, such as the plan in the
#    plan approval dialog, loses the indent its rows share.
#
# 4. Claude Code wraps text to the pane width, less up to 2 columns of
#    padding, breaking a row only where the next word won't fit. Rejoin a row
#    of a reply, or of other text from step 3, to the one before it when its
#    first word wouldn't have fitted there, so paragraphs and list items paste
#    as one line each. Breaks Claude meant (short lines, new list items, table
#    rows, rules) stay. A word longer than a row, such as a URL, rejoins with
#    no space.

use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));

my $claude = ($ARGV[0] // '') eq 'claude';
my $width = ($ARGV[1] // '') =~ /^\d+$/ ? $ARGV[1] : 0;

# Each row keeps its width and indent as drawn, which the rejoin needs.
my @rows = map { { t => $_, drawn => length, lead => /^([│▌]? *)/ ? length $1 : 0 } }
  split /\n/, do { local $/; <STDIN> // '' }, -1;

# 1. The bar
# The border lines: └──── under your message and └──── 12:34:56 ─ under a
# reply (older versions drew a ┌──── line over a reply, and blank barred
# rows inside it). Each, with any blank barred row beside it, becomes one
# blank line between messages, or goes at either end of the copy.
my @kept;
for my $row (@rows) {
  my $last = $kept[-1];
  if ($row->{t} =~ /^[└┌]─(?:[─ ]|\d\d:\d\d:\d\d)*$/) {
    if ($last && $last->{t} =~ /^[│▌]?\s*$/) { $last->{floor} = 1 }
    else { push @kept, { t => '', drawn => 0, lead => 0, floor => 1 } }
    next;
  }
  next if $last && $last->{floor} && $row->{t} =~ /^[│▌]\s*$/;
  push @kept, $row;
}
@rows = @kept;
shift @rows while @rows && $rows[0]{floor};
pop @rows while @rows && $rows[-1]{floor};
for (@rows) { $_->{kind} = 'bar' if $_->{t} =~ s/^[│▌] ?// }
# A reply's blank first and last rows, at either end of the copy, go.
my $blank = sub { ($_[0]{kind} // '') eq 'bar' && $_[0]{t} =~ /^\s*$/ };
shift @rows while @rows && $blank->($rows[0]);
pop @rows while @rows && $blank->($rows[-1]);
my @bars = grep { $_->{kind} } @rows;
if (@bars) {
  # A first row with no bar, above a bar row, is a selection that began at
  # the text: 4 columns in for a reply, whose rows below are indented, or 2
  # for your own message, whose rows aren't.
  if (@rows > 1 && !$rows[0]{kind} && ($rows[1]{kind} // '') eq 'bar') {
    my $in = $rows[1]{t} =~ /^\S/ ? 2 : 4;
    $rows[0]{kind} = 'bar';
    $rows[0]{drawn} += $in;
    $rows[0]{lead} = $in;
    $rows[0]{partial} = 1;
  }
  $_->{t} =~ s/^(\s*)[⏺❯] /$1  / for @bars;
  # Each run of bar rows between └──── lines (or what stands in for them) is
  # one message. Dedent each on its own, as your messages sit 2 columns left
  # of Claude's replies. A first row that began at the text has no indent to
  # lose.
  my @run;
  for my $row (@rows, {}) {
    if (($row->{kind} // '') eq 'bar' && !$row->{partial} && !$row->{floor}) { push @run, $row; next }
    next if $row->{partial};
    dedent(grep { $_->{t} !~ /^\[\d\d:\d\d:\d\d\] =+$/ } @run);
    @run = ();
  }
}

if ($claude) {
  # 2. Line numbers
  @rows = strip_numbers(@rows);

  # 3. Other text. The first row may start at the text, past the indent.
  my @plain = grep { !$_->{kind} } @rows;
  $_->{kind} = 'plain' for @plain;
  my $first = @plain && $plain[0] == $rows[0] ? shift @plain : undef;
  my $min = dedent(@plain);
  if ($first) {
    my ($own) = $first->{t} =~ /^( *)/;
    if (defined $min && length $own < $min) {
      $first->{drawn} += $min - length $own;
      $first->{lead} = $min;
    }
    $first->{t} =~ s/^ {0,$min}// if $min;
  }
}

# 4. Rejoin
@rows = rejoin(@rows) if $width;
print join "\n", map { $_->{t} } @rows;

# Remove the indent the rows' text shares, ignoring blank rows and rules such as
# ──── that hold no words. Returns it.
sub dedent {
  my ($min) = sort { $a <=> $b } map { $_->{t} =~ /^( *)/; length $1 } grep { $_->{t} =~ /\w/ } @_;
  if ($min) { $_->{t} =~ s/^ {0,$min}// for @_ }
  return $min;
}

sub rejoin {
  my @out;
  for my $i (0 .. $#_) {
    my ($prev, $row) = ($_[$i - 1], $_[$i]);
    my $kind = $row->{kind} // '';
    if ($i && ($kind eq 'bar' || $kind eq 'plain') && ($prev->{kind} // '') eq $kind
      && wrapped($prev->{t}, $prev->{drawn}, $row->{t})) {
      (my $t = $row->{t}) =~ s/^\s+//;
      my ($tail) = $out[-1]{t} =~ /(\S+)$/;
      my ($head) = $t =~ /^(\S+)/;
      my $split = $prev->{drawn} >= $width - 2 && length($tail . $head) > $width - $row->{lead};
      $out[-1]{t} .= ($split ? '' : ' ') . $t;
      next;
    }
    push @out, { %$row };
  }
  return @out;
}

sub wrapped {
  my ($prev, $drawn, $next) = @_;
  return 0 unless $prev =~ /\w/ && $next =~ /\w/;
  return 0 if $prev =~ /^\[\d\d:\d\d:\d\d\] =+$/;
  return 0 if $next =~ /^\s*(?:[-*+•]|\d+[.)])\s/;
  return 0 if $next =~ /^\s*[│├└┌╭╰|]/ || $prev =~ /[│┤┐┘╮╯|]\s*$/;
  my ($word) = $next =~ /^\s*(\S+)/;
  return $drawn + 1 + length($word) > $width - 2;
}

# Group numbered rows, and the unnumbered rows that continue them, into
# blocks, and hand each block to render. Bar rows are prose, never code.
sub strip_numbers {
  my (@out, @blk, $col);
  for my $i (0 .. $#_) {
    my $row = $_[$i];
    # The first row may start mid-gutter; later ones come from the left edge.
    my $lead = $i == 0 ? 0 : 2;
    if (!$row->{kind} && $row->{t} =~ /^( {$lead,})(\d+)(?: (.*))?$/) {
      $col = length($1) + length($2) + 1;
      push @blk, { row => $row, n => $2, lead => length $1, rest => $3 // '' };
    } elsif (@blk && !$row->{kind} && $row->{t} =~ /^ {$col}(.*)$/) {
      push @blk, { row => $row, cont => 1, rest => $1 };
    } else {
      push @out, render(@blk), $row;
      @blk = ();
    }
  }
  return (@out, render(@blk));
}

# A block's rows with the numbers gone, or as they were if it isn't code.
sub render {
  my @b = @_;
  my @num = grep { !$_->{cont} } @b;
  my @raw = map { $_->{row} } @b;
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
  return map { { t => $_, kind => 'code' } } @out;
}
