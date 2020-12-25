use 5.14.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::TestForGithubActions;

use Moose;
with qw/
    Dist::Zilla::Plugin::Author::CSSON::GithubActions::Role::Workflow
/;

sub filepath { 'share/test-workflow.yml' }

1;
