use 5.14.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Author::CSSON::GithubActions::Workflow::TestWithMakefile;

# ABSTRACT: Workflow for testing with Makefile.PL
# AUTHORITY
our $VERSION = '0.0104';

use Moose;
with qw/
    Dist::Zilla::Plugin::Author::CSSON::GithubActions
/;

has run_before => (
    is => 'ro',
    isa => ArrayRef,
    default => sub { [] },
    traits => ['Array'],
    documentation => q{Adds one or more steps before installing Perl modules},
    handles => {
        all_run_before => 'elements',
        has_run_before => 'count',
    },
);

sub mvp_multivalue_args {
    my $self = shift;
    my @defaults = @_;

    return @defaults, qw/
        run_before
    /;
};

sub workflow_filename { 'workflow-test-with-makefile.yml' }

#sub main_module { 'Dist::Zilla::Plugin::Author::CSSON::GithubActions' }

#sub filepath { 'base-workflow.yml' }




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