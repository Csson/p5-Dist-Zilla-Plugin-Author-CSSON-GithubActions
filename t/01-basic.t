use strict;
use warnings;
use Test::More;
use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';

use lib 't/corpus/lib';
use Dist::Zilla::Plugin::Author::CSSON::GithubActions;
use Test::Exception;
use Test::DZil;
use Path::Tiny;
use YAML::XS qw/LoadFile/;

ok 1, 'Loaded';

my $tests = [
    {
        name => '1',
        settings => {},
        check => sub {
            my $tzil = shift;
            my $yaml = shift;
            is_deeply $yaml->{'on'}{'push'}{'branches'}, ['*'] or diag explain $yaml;
        },
    },
    {
        settings => {
            clear_on_push_branches => 1,
        },
        check => sub {
            my $tzil = shift;
            my $yaml = shift;
            is_deeply $yaml->{'on'}{'push'}{'branches'}, [] or diag explain $yaml;
            is_deeply $yaml->{'on'}{'pull_request'}{'branches'}, ['*'] or diag explain $yaml;
        }
    },
    {
        settings => {
            clear_on_pull_request_branches => 1,
        },
        check => sub {
            my $tzil = shift;
            my $yaml = shift;
            is_deeply $yaml->{'on'}{'push'}{'branches'}, ['*'] or diag explain $yaml;
            is_deeply $yaml->{'on'}{'pull_request'}{'branches'}, [] or diag explain $yaml;
        }
    },
    {
        settings => {
            on_pull_request_branches => [qw/this that/]
        },
        check => sub {
            my $tzil = shift;
            my $yaml = shift;
            is_deeply $yaml->{'on'}{'pull_request'}{'branches'}, ['*', 'this', 'that'], or diag explain $yaml;
        }
    },
    {
        settings => {
            clear_on_pull_request_branches => 1,
            on_pull_request_branches => [qw/this that/]
        },
        check => sub {
            my $tzil = shift;
            my $yaml = shift;
            is_deeply $yaml->{'on'}{'pull_request'}{'branches'}, ['this', 'that'], or diag explain $yaml;
        }
    },
];

for my $test (@{ $tests }) {
    my $tzil = make_tzil($test->{'settings'});
    my $yaml = LoadFile(path($tzil->tempdir)->child('source/.github/workflows/test-workflow-output.yml'));

    if (exists $test->{'check'}) {
        $test->{'check'}($tzil, $yaml);
    }
}

done_testing;

sub make_tzil {
    my %settings = %{ shift() };
    my $ini = simple_ini(
        { version => '0.0002' },
        [ 'Author::CSSON::GithubActions', {
            workflow_class => 'TestForGithubActions',
            %settings,
        }],
        qw/
            GatherDir
            FakeRelease
        /,
    );

    my $tzil = Builder->from_config(
        {   dist_root => 't/corpus' },
        {
            add_files => {
                'source/dist.ini' => $ini,
                'source/share/test-workflow.yml' => path('t/corpus/test-workflow.yml')->slurp,
                'source/t/corpus/lib/Dist/Zilla/Plugin/TestForGithubActions.pm' => path('t/corpus/lib/Dist/Zilla/Plugin/TestForGithubActions.pm')->slurp,
            },
        },
    );
    $tzil->build;

    lives_ok(sub { $tzil }, 'Distro built')  || explain $tzil->log_messages;
    return $tzil;
}
