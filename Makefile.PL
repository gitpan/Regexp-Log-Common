use ExtUtils::MakeMaker;
WriteMakefile(
    NAME          => 'Regexp::Log::Common',
    VERSION_FROM  => 'lib/Regexp/Log/Common.pm',
    PREREQ_PM     => {
		'Test::More'  => 0.47,
		'Regexp::Log' => 0
	},
	NO_META			=> 1,

    ABSTRACT_FROM => 'lib/Regexp/Log/Common.pm',
    AUTHOR        => 'Barbie <barbie@cpan.org>',
);
