#!/opt/local/bin/perl
use strict;
use utf8;
use XML::Simple;
use Encode;
use File::Basename;
use File::Copy;
use MP3::Tag;

my $xml = new XML::Simple;

# First argument is source master smil
my ($file, $source) = fileparse($ARGV[0]);
# Second argument is dest path
my $dest = $ARGV[1];

# Read master smil
my $data = $xml->XMLin("$source$file");

# Get body ref
my $refs = $data->{"body"}->{'ref'};

# Get title from head
my $book_title = encode("iso-8859-1", $data->{"head"}->{"meta"}->{"dc:title"}->{"content"});

# Open playlist file for writing 
open (PLAYLISTFILE, ">>$dest\playlist.m3u");

# Track number
my $track_no = 0;

# Loop over refs
for my $key (sort keys %$refs){
    $track_no = $track_no + 1;
    my $value = $$refs{$key};
    my $filename = encode("iso-8859-1",$$value{'src'});
    my $title = encode("iso-8859-1",$$value{'title'}); 
    $filename =~ s/^(.+)(\..+)$/$1.mp3/g;
    
    # Add file to playlist
    print PLAYLISTFILE "$filename\n";

    # Copy file to destination
    copy("$source$filename", "$dest$filename") or die "Error: Couldn't copy $filename.";
    
    # Set mp3 tags
    my $mp3 = MP3::Tag->new("$dest$filename");
    $mp3->title_set($title);
    $mp3->album_set($book_title);
    $mp3->track_set($track_no);
    $mp3->genre_set("Audiobook");
    $mp3->update_tags();
    $mp3->close();
}

close(PLAYLISTFILE);
