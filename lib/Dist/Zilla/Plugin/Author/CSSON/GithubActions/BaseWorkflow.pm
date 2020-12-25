use 5.14.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Author::CSSON::GithubActions::BaseWorkflow;

# ABSTRACT: An example Github Actions workflow
# AUTHORITY
our $VERSION = '0.0101';

use Moose;
with qw/
    Dist::Zilla::Plugin::Author::CSSON::GithubActions::Role::Workflow
/;

sub filepath { 'share/base-workflow.yml' }

1;

=pod

=head1 SYNOPSIS

In dist.ini:

    [Author::CSSON::GithubActions]
    workflow_class = Author::CSSON::GithubActions::BaseWorkflow

=head1 DESCRIPTION

This is an example workflow for L<Dist::Zilla::Plugin::Author::CSSON::GithubActions>. It is based
on L<https://perlmaven.com/setup-github-actions>.

The actual workflow is defined in C<share/base-workflow.yml>.