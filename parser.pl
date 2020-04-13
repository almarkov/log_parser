#!/usr/bin/perl
use DBI;
use DBD::Pg;
use Data::Dumper;

my $dbname   = 'sample';
my $host     = 'localhost';
my $port     = '5432';
my $username = 'sample';
my $password = 'praznic666_';

my $dbh = DBI -> connect("dbi:Pg:dbname=$dbname;host=$host;port=$port",
    $username,
    $password,
    {AutoCommit => 0, RaiseError => 1}
) or die $DBI::errstr;

my $batch_size = 100;
my $file       = 'out';

$file_path  = $ARGV[0] if @ARGV > 0;
$batch_size = $ARGV[1] if @ARGV > 1;

open my $in, "<:encoding(utf8)", $file or die "$file: $!";

my (@messages, @logs);

while (my $line = <$in>) {

    chomp $line;
    my ($date, $time, $int_id, $str) = split(' ', $line, 4);
    
    if ($str =~ /^<=/) {
        if ($str =~ /id=(.+)/) {
            my $id = $1;
            push @messages, {
                created => $date.' '.$time,
                int_id  => $int_id,
                str     => $str,
                id      => $id,
            };

            if (scalar(@messages) == $batch_size) {
                insert_messages(\@messages);
                @messages = ();
            }
        }
    }
    elsif ($str =~ /^(=>|->|\*\*|==) (.+?) /) {
        $address = $2;
        push @logs, {
            created => $date.' '.$time,
            int_id  => $int_id,
            str     => $str,
            address => $address,
        };

        if (scalar(@logs) == $batch_size) {
            insert_logs(\@logs);
            @logs = ();
        }
    }
}

insert_logs(\@logs) if @logs;
insert_messages(\@messages) if @messages;

close $in;

$dbh->commit or die $DBI::errstr;

$dbh -> disconnect;



sub insert_messages {
    my $items = shift;

    my $qs = '(?,?,?,?),' x @$items; chop ($qs);

    my $sql = "INSERT INTO message(created, int_id, str, id) VALUES $qs";

    my $sth = $dbh->prepare($sql);

    $sth->execute(map { $_->{created}, $_->{int_id}, $_->{str}, $_->{id} } @$items);
}


sub insert_logs {
    my $items = shift;

    my $qs = '(?,?,?,?),' x @$items; chop ($qs);

    my $sql = "INSERT INTO log(created, int_id, str, address) VALUES $qs";

    my $sth = $dbh->prepare($sql);

    $sth->execute(map { $_->{created}, $_->{int_id}, $_->{str}, $_->{address} } @$items);
}


