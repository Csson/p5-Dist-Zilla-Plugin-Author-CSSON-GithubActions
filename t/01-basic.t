use strict;
use warnings;
use Test::More;
use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';

use lib 't/corpus/lib';
use Dist::Zilla::Plugin::Author::CSSON::GithubActions;
use Test::DZil;
use Module::Load qw/load/;

ok 1, 'Loaded';

my $tzil = make_tzil();

lives_ok(sub { $tzil->build }, 'Distro built')  || explain $tzil->log_messages;

done_testing;

sub make_tzil {
    my $ini = simple_ini(
        { version => '0.0002' },
        [ 'Author::CSSON::GithubActions', { profile_class => 'Author::CSSON::GithubActions::BaseWorkflow' } ],
        qw/

        /,
    );

    my $tzil = Builder->from_config(
        {   dist_root => '/t' },
        {
            add_files => {
                'source/dist.ini' => $ini,
            },
        },
    );
    $tzil->build;
    return $tzil;
}