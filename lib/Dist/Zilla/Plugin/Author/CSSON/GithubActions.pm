use 5.14.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Author::CSSON::GithubActions;

# ABSTRACT: Ease creation of common Github Actions workflows
# AUTHORITY
our $VERSION = '0.0100';

use Moose;
use namespace::autoclean;
use Path::Tiny;
use Types::Standard qw/ArrayRef Bool/;
use Module::Load qw/load/;

with qw/
    Dist::Zilla::Role::Plugin
    Dist::Zilla::Role::InstallTool
/;

sub mvp_multivalue_args {
    qw/
        on_push_branches
        on_pull_request_branches
        matrix_os
        perl_versions
    /;
}

has profile_class => (
    is => 'ro',
    required => 1,
    documentation => q{The 'profile_class' will be prefix with 'Dist::Zilla::Plugin' },
);
has clear_on_push_branches => (
    is => 'ro',
    isa => Bool,
    default => sub { 0 },
    documentation => q{Clears the on.push.branches setting from the base workflow},
);
has clear_on_pull_request_brances => (
    is => 'ro',
    isa => Bool,
    default => sub { 0 },
    documentation => q{Clears the on.pull_request.branches setting from the base workflow},
);

has on_push_branches => (
    is => 'ro',
    isa => ArrayRef,
    default => sub { [] },
    documentation => q{Add more branches to on.push.branches},
);
has on_pull_request_branches => (
    is => 'ro',
    isa => ArrayRef,
    default => sub { [] },
    documentation => q{Add more branches to on.pull_request.branches},
);
has matrix_os => (
    is => 'ro',
    isa => ArrayRef,
    default => sub { [] },
    documentation => q{If defined, replaces the matrix.os setting},
);
has perl_versions => (
    is => 'ro',
    isa => ArrayRef,
    default => sub { [] },
    documentation => q{If defined, replaces the matrix.perl-version setting},
);

sub setup_installer {
    my $self = shift;

    #use lib '/home/erik/sw/dists/Dist-Zilla-Plugin-Author-CSSON-GithubActions/t/corpus/lib';
    my $class_name = 'Dist::Zilla::Plugin::' . $self->profile_class;
    load $class_name;

    my $profile = $class_name->new;
    die $profile->filepath;
}

1;

__END__

=pod

=head1 SYNOPSIS

    use Dist::Zilla::Plugin::Author::CSSON::GithubActions;

=head1 DESCRIPTION

Dist::Zilla::Plugin::Author::CSSON::GithubActions is ...

=head1 SEE ALSO

=cut
