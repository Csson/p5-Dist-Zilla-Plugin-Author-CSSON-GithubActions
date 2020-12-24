use 5.14.0;
use strict;
use warnings;

package Dist::Zilla::Plugin::Author::CSSON::GithubActions::Role::Workflow;

# ABSTRACT: Role for GithubActions workflows
# AUTHORITY
our $VERSION = '0.0100';

use Moose::Role;
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

1;
