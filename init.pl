#!/usr/bin/perl
use DBI;
use DBD::Pg;

my $dbname   = 'sample';
my $host     = 'localhost';
my $port     = '5432';
my $username = 'sample';
my $password = 'sample';

my $dbh = DBI -> connect("dbi:Pg:dbname=$dbname;host=$host;port=$port",
    $username,
    $password,
    {AutoCommit => 0, RaiseError => 1}
) or die $DBI::errstr;

my $init_sql = q{
CREATE TABLE message (
    created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    id VARCHAR NOT NULL,
    int_id CHAR(16) NOT NULL,
    str VARCHAR NOT NULL,
    status BOOL,
    CONSTRAINT message_id_pk PRIMARY KEY(id)
);
CREATE INDEX message_created_idx ON message (created);
CREATE INDEX message_int_id_idx ON message (int_id);

CREATE TABLE log (
    created TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    int_id CHAR(16) NOT NULL,
    str VARCHAR,
    address VARCHAR
);
CREATE INDEX log_address_idx ON log USING hash (address);
};

my $sth = $dbh->do($init_sql);

$dbh->commit or die $DBI::errstr;

$dbh -> disconnect;