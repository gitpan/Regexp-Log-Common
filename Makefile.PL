use ExtUtils::MakeMaker;
WriteMakefile(
    NAME          => 'Regexp::Log::Common',
    VERSION_FROM  => 'lib/Regexp/Log/Common.pm',
    PREREQ_PM     => {
		'Test::More'  => 0,
		'Regexp::Log' => 0
	},
    ABSTRACT_FROM => 'lib/Regexp/Log/Common.pm',
    AUTHOR        => 'Barbie <barbie@cpan.org>',
);
