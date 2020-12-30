use 5.14.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Author::CSSON::GithubActions;

# ABSTRACT: Ease creation of common Github Actions workflows
# AUTHORITY
our $VERSION = '0.0108';

=pod

=head1 SYNOPSIS

In dist.ini:

    [Author::CSSON::GithubActions::Workflow::TestWithMakefile]
    ; set on.push.branches to an empty list
    clear_on_push_branches = 1

    ; set on.pull_request.branches to an empty list
    clear_on_pull_request_branches = 1

    ; add branches to on.push.branches
    on_pull_request_branches = 'this-branch'
    on_pull_request_branches = 'that-other-branch'

    ; add branches to on.pull_request.branches
    on_pull_request_branches = 'my-pr-branch'
    on_pull_request_branches = 'feature-branch'

    ; replace jobs.perl-job.strategy.matrix.os
    matrix_os = ubuntu-latest
    matrix_os = ubuntu-16.04

    ; replace jobs.perl-job.strategy.matrix.perl-version
    perl_version = 5.32
    perl_version = 5.24
    perl_version = 5.18

=head1 STATUS

This plugin is very early in development. It might be released in a non-author namespace at a later stage.

=head1 DESCRIPTION

This distribution is a framework for creating re-usable Github Actions workflows. GitHub's documentation about Actions is located at L<http://docs.github.com/en/free-pro-team@latest/actions>.

The core of it is the L<Dist::Zilla::Role::Author::CSSON::GithubActions> role.

Included in this distribution is an example workflow, L<Dist::Zilla::Plugin::Author::CSSON::GithubActions::Workflow::TestWithMakefile>.

=head1 SEE ALSO

=for :list
* L<Dist::Zilla::TravisCI>
* L<http://docs.github.com/en/free-pro-team@latest/actions>
* L<https://perlmaven.com/setup-github-actions>
