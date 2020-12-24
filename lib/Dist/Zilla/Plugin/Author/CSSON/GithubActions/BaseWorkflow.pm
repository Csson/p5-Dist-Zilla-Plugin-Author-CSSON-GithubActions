use 5.14.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Author::CSSON::GithubActions::BaseWorkflow;

use Moose;
with qw/
    Dist::Zilla::Plugin::Author::CSSON::GithubActions::Role::Workflow
/;

sub filepath { 'share/base-workflow.yml' }

1;
