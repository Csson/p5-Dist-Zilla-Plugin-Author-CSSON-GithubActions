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
use Types::Standard qw/ArrayRef Bool Str/;
use Module::Load qw/load/;
use YAML::XS qw/Dump/;
use List::AllUtils qw/first/;
use Path::Class::File;
use Dist::Zilla::File::InMemory;

with qw/
    Dist::Zilla::Role::Plugin
    Dist::Zilla::Role::FileGatherer
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
    documentation => q{Clears the on.push.branches setting from the base workflow (if that setting is used in the config)},
);
has clear_on_pull_request_branches => (
    is => 'ro',
    isa => Bool,
    default => sub { 0 },
    documentation => q{Clears the on.pull_request.branches setting from the base workflow (if that setting is used in the config)},
);

for my $setting (qw/on_push_branches on_pull_request_branches/) {
    has $setting => (
        is => 'ro',
        isa => ArrayRef,
        default => sub { [] },
        traits => ['Array'],
        documentation => q{Add more branches to on.push.branches *or* on.pull_request.branches},
        handles => {
            "all_$setting" => 'elements',
            "has_$setting" => 'count',
        },
    );
}
has matrix_os => (
    is => 'ro',
    isa => ArrayRef,
    default => sub { [] },
    documentation => q{If defined, replaces the matrix.os setting},
);
has perl_version => (
    is => 'ro',
    isa => ArrayRef,
    default => sub { [] },
    documentation => q{If defined, replaces the matrix.perl-version setting},
);

has filename => (
    is => 'rw',
    isa => Str,
    predicate => 'has_filename',

);

sub _prepare_yaml {
    my $self = shift;

    my $class_name = 'Dist::Zilla::Plugin::' . $self->profile_class;
    load $class_name;

    my $profile = $class_name->new;
    my $yaml = $class_name->yaml;

    if ($self->clear_on_push_branches && exists $yaml->{'on'}{'push'}{'branches'}) {
        $yaml->{'on'}{'push'}{'branches'} = [];
    }
    if ($self->clear_on_pull_request_branches && exists $yaml->{'on'}{'pull_request'}{'branches'}) {
        $yaml->{'on'}{'pull_request'}{'branches'} = [];
    }

    if ($self->has_on_push_branches) {
        push @{ $yaml->{'on'}{'push'}{'branches'} } => $self->all_on_push_branches;
    }
    if ($self->has_on_pull_request_branches) {
        push @{ $yaml->{'on'}{'pull_request'}{'branches'} } => $self->all_on_pull_request_branches;
    }
    return $yaml;
}

sub _write_yaml {
    my $self = shift;
    my $yaml = shift;

    my $file = Path::Class::File->new(split m{/} => $self->filepath($yaml));
    $file->spew(Dump($yaml));
    return $file;
}

sub filepath {
    my $self = shift;
    my $yaml = shift;

    if ($self->has_filename) {
        delete $yaml->{'filename'};
    }
    elsif (exists $yaml->{'filename'}) {
        $self->filename(delete $yaml->{'filename'});
    }
    my $path = path($self->zilla->built_in ? $self->zilla->built_in : (), '.github', 'workflows', $self->filename);
    $path->touchpath;
    return $path->stringify;
}

sub gather_files {
    my $self = shift;

    my $yaml = $self->_prepare_yaml;
    $self->_write_yaml($yaml);

    my $generated_file = Dist::Zilla::File::InMemory->new({
        name => $self->filepath($yaml),
        content => Dump($yaml),
    });
    $self->add_file($generated_file);

}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 SYNOPSIS

In dist.ini:

    [Author::CSSON::GithubActions]
    ; profile_class is mandatory (Dist::Zilla::Plugin is prepended when loading it)
    profile_class = Author::CSSON::GithubActions::BaseWorkflow

    ; the rest is optional, and customizes the workflow defined in the profile_class

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

This is very early in development.

=head1 DESCRIPTION

This plugin creates a Github Actions workflow file in C<.github/workflows>.

Note that, if you plan to use the customizations shown above, the following settings in the workflow YAML file are expected to be defined as lists and not strings:
* C<on.push.branches>
* C<on.pull_request.branches>
* C<jobs.perl-job.strategy.matrix.os>
* C<jobs.perl-job.strategy.matrix.perl-version>

See L<Dist::Zilla::Plugin::Author::CSSON::GithubActions::Role::Workflow> for how to define a workflow.

See L<Dist::Zilla::Plugin::Author::CSSON::GithubActions::BaseWorkflow> for an example workflow.

=head1 SEE ALSO

=for :list
* L<Dist::Zilla::TravisCI>

=cut
