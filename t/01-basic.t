use strict;
use warnings;
use Test::More;
use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';

use Dist::Zilla::Plugin::Author::CSSON::GithubActions;
ok 1, 'Loaded';

done_testing;
