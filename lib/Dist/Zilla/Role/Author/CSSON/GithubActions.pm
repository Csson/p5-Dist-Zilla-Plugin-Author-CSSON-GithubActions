use 5.14.0;
use strict;
use warnings;

package Dist::Zilla::Role::Author::CSSON::GithubActions;

# ABSTRACT: Role for Github Actions workflows
# AUTHORITY
our $VERSION = '0.0104';

use Moose::Role;
use namespace::autoclean;
use Path::Tiny;
use Try::Tiny;
use Types::Standard qw/ArrayRef Bool Str HashRef/;
use Types::Path::Tiny qw/Path/;
use File::ShareDir qw/dist_dir/;
use YAML::XS qw/Dump Load/;
use List::AllUtils qw/first/;
use Path::Class::File;
use Dist::Zilla::File::InMemory;

with qw/
    Dist::Zilla::Role::Plugin
    Dist::Zilla::Role::FileGatherer
    Dist::Zilla::Role::FilePruner
/;

requires 'workflow_filename';

around mvp_multivalue_args => sub {
    my $orig = shift;
    my $self = shift;

    return $self->$orig(), qw/
        on_push_branches
        on_pull_request_branches
        matrix_os
        perl_versions
    /;
};

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
    documentation => q{If defined, the filename of the generated workflow file},
    predicate => 'has_filename',
);



has generated_filepath => (
    is => 'rw',
    isa => Path,
    predicate => 'has_generated_filename',
);
has generated_yaml => (
    is => 'rw',
    isa => HashRef,
);

# Override this in the Workflow if needed
sub parse_custom_parameters { }

sub distribution_name { shift->zilla->name }

sub _prepare {
    my $self = shift;

    # Read the workflow file
    my $package = $self->distribution_name;

    my $dir = path('.');
    try {
        $dir = path(dist_dir($package));
    }
    finally { };

    my $workflow_path = $dir->child($self->workflow_filename);

    # Read YAML from the included workflow file, and modify that YAML from the dist.ini configuration
    my $yaml = Load($workflow_path->slurp);

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

    my $generated_filename = $self->has_filename ? $self->filename
                           : exists $yaml->{'filename'} ? delete $yaml->{'filename'}
                           : $self->workflow_filename;

    $yaml = $self->parse_custom_parameters($yaml);
    $self->generated_yaml($yaml);

    # Prepare the path where the generated workflow file will be saved (.github/workflows/...)
    my $path = path($self->zilla->built_in ? $self->zilla->built_in : (), '.github', 'workflows', $generated_filename);
    $path->touchpath;
    $self->generated_filepath($path);
    return $self;

}

sub gather_files {
    my $self = shift;
    $self->_prepare;

    my $rendered_yaml = Dump($self->generated_yaml);
    $self->generated_filepath->spew($rendered_yaml);

    my $generated_file = Dist::Zilla::File::InMemory->new({
        name => $self->generated_filepath->stringify,
        content => Dump($rendered_yaml),
    });
    $self->add_file($generated_file);

}

sub prune_files {
    my $self = shift;

    my $file = first { $_->name eq $self->generated_filepath } @{ $self->zilla->files };

    $self->zilla->prune_file($file) if $file;
}

1;

__END__

=pod

=head1 SYNOPSIS

In dist.ini:

    [MyWorkflow]
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


=head1 DESCRIPTION

This role exposes some parameters creates a Github Actions workflow file in C<.github/workflows>.

Note that, if you plan to use the customizations shown above, the following settings in the workflow YAML file are expected to be defined as lists and not strings:
* C<on.push.branches>
* C<on.pull_request.branches>
* C<jobs.perl-job.strategy.matrix.os>
* C<jobs.perl-job.strategy.matrix.perl-version>

Also, it is assumed that the step where the distribution is tested is named C<perl-job>.

The generated workflow file will be created in C<.github/workflows>. The filename will be (in order of priority):
=for :list
* The value of the C<filename> parameter in C<dist.ini>
* The value of the C<filename> key in the C<$workflow.yml> file
* The name of the C<$workflow.yml> file

See L<Dist::Zilla::Plugin::Author::CSSON::GithubActions::Workflow::TestWithMakefile> for an example workflow.

=cut
