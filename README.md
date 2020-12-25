# NAME

Dist::Zilla::Plugin::Author::CSSON::GithubActions - Ease creation of common Github Actions workflows

<div>
    <p>
    <img src="https://img.shields.io/badge/perl-5.10+-blue.svg" alt="Requires Perl 5.10+" />
    <a href="http://cpants.cpanauthors.org/release/CSSON/Dist-Zilla-Plugin-Author-CSSON-GithubActions-0.0101"><img src="http://badgedepot.code301.com/badge/kwalitee/CSSON/Dist-Zilla-Plugin-Author-CSSON-GithubActions/0.0101" alt="Distribution kwalitee" /></a>
    <a href="http://matrix.cpantesters.org/?dist=Dist-Zilla-Plugin-Author-CSSON-GithubActions%200.0101"><img src="http://badgedepot.code301.com/badge/cpantesters/Dist-Zilla-Plugin-Author-CSSON-GithubActions/0.0101" alt="CPAN Testers result" /></a>
    <img src="https://img.shields.io/badge/coverage-92.3%-yellow.svg" alt="coverage 92.3%" />
    </p>
</div>

# VERSION

Version 0.0101, released 2020-12-25.

# SYNOPSIS

In dist.ini:

    [Author::CSSON::GithubActions]
    ; workflow_class is mandatory (Dist::Zilla::Plugin is prepended when loading it)
    workflow_class = Author::CSSON::GithubActions::BaseWorkflow

    ; the rest is optional, and customizes the workflow defined in the workflow_class

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

# STATUS

This is very early in development.

# DESCRIPTION

This plugin creates a Github Actions workflow file in `.github/workflows`.

Note that, if you plan to use the customizations shown above, the following settings in the workflow YAML file are expected to be defined as lists and not strings:
\* `on.push.branches`
\* `on.pull_request.branches`
\* `jobs.perl-job.strategy.matrix.os`
\* `jobs.perl-job.strategy.matrix.perl-version`

See [Dist::Zilla::Plugin::Author::CSSON::GithubActions::Role::Workflow](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::CSSON::GithubActions::Role::Workflow) for how to define a workflow.

See [Dist::Zilla::Plugin::Author::CSSON::GithubActions::BaseWorkflow](https://metacpan.org/pod/Dist::Zilla::Plugin::Author::CSSON::GithubActions::BaseWorkflow) for an example workflow.

# SEE ALSO

- [Dist::Zilla::TravisCI](https://metacpan.org/pod/Dist::Zilla::TravisCI)

# SOURCE

[https://github.com/Csson/p5-Dist-Zilla-Plugin-Author-CSSON-GithubActions](https://github.com/Csson/p5-Dist-Zilla-Plugin-Author-CSSON-GithubActions)

# HOMEPAGE

[https://metacpan.org/release/Dist-Zilla-Plugin-Author-CSSON-GithubActions](https://metacpan.org/release/Dist-Zilla-Plugin-Author-CSSON-GithubActions)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Erik Carlsson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
