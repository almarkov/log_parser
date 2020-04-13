#!/usr/bin/perl
use strict;
use warnings;

use Plack::Request;
use DBD::Pg;
use Data::Dumper;

my $dbname = 'sample';
my $host   = 'localhost';
my $port   = '5432';
my $username = 'sample';
my $password = 'sample';

my $dbh = DBI -> connect("dbi:Pg:dbname=$dbname;host=$host;port=$port",
    $username,
    $password,
    {AutoCommit => 0, RaiseError => 1}
) or die $DBI::errstr;
 
my $app = sub {
    my $env = shift;
 
    my $html = form_html();
 
    my $request = Plack::Request->new($env);
 
    if ($request->param('q')) {

        my $items = $dbh->selectall_arrayref(q{
            WITH int_ids AS(
                SELECT
                    DISTINCT int_id AS id
                FROM
                    log
                WHERE
                    address LIKE ?
            )
            SELECT
                created
                , str
                , int_id
            FROM
                log INNER JOIN int_ids ON int_ids.id = log.int_id 
            UNION
            SELECT
                created
                , str
                , int_id
            FROM
                message INNER JOIN int_ids ON int_ids.id = message.int_id 
            ORDER BY int_id, created
            LIMIT 101
        },{
            Slice => {}
        }, $request->param('q'));

        if (@$items == 0) {

            $html .= 'Nothing found';

        }
        else {

            if (@$items > 100) {
                $html .= 'Found more than 100 records';
                pop @$items;
            }

            $html .= '<table>';
            $html .= "<tr><td>$$_{created}</td><td>$$_{str}</td></tr>" for @$items;
            $html .= '</table>';

        }
    }
 
    return [
        '200',
        [ 'Content-Type' => 'text/html' ],
        [ $html ],
    ];
}; 
 
sub form_html {
    return q{
        <form>
            <input name="q">
            <input type="submit" value="Search">
        </form>
        <hr>
    }
}