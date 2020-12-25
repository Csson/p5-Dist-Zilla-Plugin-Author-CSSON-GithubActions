use 5.14.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Author::CSSON::GithubActions::Role::Workflow;

# ABSTRACT: Role used to define a GithubActions workflow
# AUTHORITY
our $VERSION = '0.0104';

use Moose::Role;
use YAML::XS qw/Load/;
use Path::Tiny;
use File::ShareDir qw/dist_dir/;
use Try::Tiny;
requires 'filepath';

sub file_location {
    my $self = shift;
    my $package = $self->main_module;
    $package =~ s{::}{-}g;

    my $dir = path('.');
    try {
        $dir = path(dist_dir($package));
    }
    finally { };

    return $dir->child($self->filepath);
}
sub yaml {
    my $self = shift;
    return Load($self->file_location->slurp);
}

1;

=pod

=head1 SYNOPSIS

In C<share/your-workflow.yml>:

    ---
    filename: 'base-workflow.yml'
    name: 'dzil-test'
    on:
      push:
        branches:
          - '*'
      pull_request:
        branches:
          - '*'

    jobs:
      perl-job:
        name: Perl ${{ matrix.perl-version }}
        runs-on: ${{ matrix.os }}
        strategy:
          fail-fast: false
          matrix:
            perl-version:
              - '5.32'
            os:
              - 'ubuntu-latest'
        container: perldocker/perl-tester:${{ matrix.perl-version }}
        steps:
          - uses: actions/checkout@v2
          - name: Dist::Zilla tests
            run: |
              dzil authordeps --missing          | cpanm --notest
              dzil listdeps   --missing --author | cpanm
              dzil test       --release --author


=head1 DESCRIPTION

This class should be consumed by workflow classes.

The only non-standard setting in the YAML file is C<filename>. This is the filename that will be created
in the C<.github/workflows> folder in the distribution that uses this plugin.

See L<Dist::Zilla::Plugin::Author::CSSON::GithubActions::BaseWorkflow> for an example workflow.

=cut