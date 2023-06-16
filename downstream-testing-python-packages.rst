======================================================
Problems faced when downstream testing Python packages
======================================================
:Author: Michał Górny
:Date: 2023-06-16
:Version: draft
:Copyright: https://creativecommons.org/licenses/by/3.0/


.. contents::


Preamble
========
*Downstream testing* refers to the testing of software package done
by their redistributors, such as Linux distributions.  It could be done
by distro-specific CI systems, package maintainers or — as it frequently
is the case with Gentoo — even distribution users.

What makes downstream testing really useful is that it serves
a different purpose than upstream testing does.  To put it shortly,
upstream testing aims to ensure that the *current* code of the package
works in one or more reference environments, and meets quality standards
set by the package authors.  On the other hand, downstream testing aims
to ensure that a particular version of the package (possibly an old one)
works in the environment that it will be used on, or one that closely
resembles it.

To put it another way, downstream testing may differ from upstreaming
testing by:

- testing a different (possibly old) package version
- using a diferent (possibly newer) Python version
- testing against different dependency versions
- testing against an environment with additional packages installed
  (that may interfere unexpectedly)
- testing on a different operating system, architecture, hardware, setup

While these may sound inconvenient and sometimes cause false positives,
they have proven in the past to detect issues that went unnoticed by
upstream and that could have broken production setups.  Downstream
testing is important.

Unfortunately, many test suites make assumptions that cause problems for
downstream testers.  Some of them can be worked around easily, others
can not.  In this article I'd like to discuss a number of these issues.


Assuming a disposable container
===============================

Probably the most extreme category of problematic test suites are suites
assuming that they will always be run in a disposable environment.
The exact details can vary.

In a simple case, the test suite could be writing to the source
directory and causing the subsequent test runs to fail because
of preexisting artifacts.

In an extreme case, the test suite could be modifying the package files,
effectively causing the *installed* package to be broken after running
the test suite.  This could be particularly bad if the breakage couldn't
trivially be detected while installing it, so testing would result
in the exact opposite of what it was supposed to do — instead of
detecting a problem prior to installing the package, it would actually
cause one.  For example, mkdocstrings used to write into template files
installed by mkdocstrings-python [#MKDOCSTRINGS]_.

Please do not assume that the test environment is disposable.  Your test
suite will be run in development and production environments.  It may
be run more than once using the same sources, it may be run against
a package that is installed already or that is going to be installed.
Do not modify the source directory, do not modify the installed
packages.  Use temporary directories, copying the package to one
if necessary.


Requiring old package versions
==============================

In general, upstreams do understand that pinning the dependencies
of their packages to specific versions is problematic for users, and can
cause conflicts in larger projects where many different components may
require the same library.  Therefore, there is a general agreement that
packages should be ported to new versions of their dependencies.
However, this doesn't seem to be always the case when a specific
dependency is needed only to run the test suite.

This is not a problem when the test suite is run in a virtual
environment.  However, for the most precise downstream testing we are
running the test suites against system packages.  This means that
effectively we need to package and install test dependencies as well.
If your test suite works correctly only with old versions of these
packages, we need to provide and maintain these old versions.

Unfortunately, this is not a case of "add once and forget".  We need
to keep these versions working, patch support for new Python versions
in, patch regressions due to the changes in their dependencies
and so on.  Believe me, it is a lot of effort that doesn't really
benefit users.  So please, keep updating your test suite to work with
the most recent releases of all its dependencies.


Incompatibilities caused by stray packages
==========================================

A somewhat related problem (and quite unique to the Python ecosystem
at that) is caused by downstream test environments featuring more
packages than the virtual environments normally used in CI
configurations.  Again, the details vary on per-package basis.

In some cases the test failures are directly caused by the additional
packages affecting the behavior of dependencies indirectly.  This is
particularly a case with pytest plugins and other plugin systems —
to the point that Gentoo disables a few known-bad plugins by default,
and often resorts to disabling plugin autoloading entirely to work
around the problems.

In other cases, the tests are run with the assumption that some package
will not be installed.  For example, starlette depended on httpx,
and httpx has optional support for Brotli that starlette upstream did
not use in their test environment.  However, if Brotli happened to be
installed in the Gentoo test environment, starlette tests failed because
of Brotli being used [#STARLETTE]_.

In the most extreme cases, the test suite would actually expect some
optional dependency not to be installed.  This is particularly the case
with packaging-related tooling that would compare the list of packages
installed in the system, or some packages testing handling of missing
dependencies without actually verifying that they aren't installed.

Please try to make your test suite robust.  Ideally run your own tests
in multiple variants with different sets of dependencies installed
to test that all fallbacks work correctly.  Most importantly, please
be patient with us when we reporting all these weird test failures.


Use of Internet resources
=========================

This is a very wide topic.  A number of test suites use Internet in some
way — from downloading test data, to actually testing the package
against live API and websites.  This causes problems on many fronts.

Sometimes *unauthorized* automated access to data can range from being
a Terms of Service violation to being simply unethical.  Just imagine
you're paying for a small server, and somebody's test suite keeps
repeatedly adding traffic, inflating your bills or decreasing
availability and performance for your actual users.

For downstreams, Internet uses poses a number of user-facing risks
and issues:

- The test suite could be run in an environment without or with severely
  retricted (firewalled) Internet access.  As a matter of fact, there
  actually are Gentoo systems that are permitted only to access a local
  distfile mirror that is used to provide package sources.

- The user could be using an Internet connection with a limited data
  plan.  The implicit use of Internet from the test suite could actually
  cause charges.

- The user could be having an unstable Internet connection (e.g. due to
  poor reception), or the service can be having temporary issues.  Even
  if your test suite initially detects a working connection and decides
  to run tests requiring remote services, the connection may terminate
  or be shoddy, and subsequently cause some of the tests to fail.

- Implicitly accessing third party services poses a privacy, and in some
  cases even a *security risk*.  In the extreme case you're exposing
  that a certain machine is running the test suite of a certain version
  of a certain software.

- Finally, as the services change, the test suite starts failing.
  It could cause sudden CI failures for you and the pull requests
  submitted to your project, but more importantly, it means that the
  tests in previously released versions will now fail permanently.

Just to bring one late example, pycares and aiodns both started failing
due to DNS records changing  [#PYCARES]_ [#AIODNS]_.

Please make sure that at least a reasonable subset of your tests can
work fully offline.  If you include online tests in your test suite,
please make them opt-in to ensure that the users' privacy is respected.
There are a number of solutions to turn online tests into offline,
depending on your actual use case.

If your tests need additional data files, please make sure that they can
be redistributed legally and either include them in your package, or
host them yourself and make it possible for redistributors to supply
them externally.  To list two examples, cryptography uses a separate
cryptography-vectors package to supply the test vectors, and pypdf uses
a sample-files repository [#CRYPTOGRAPHY-VECTORS]_
[#PY-PDF-SAMPLE-FILES]_.

If your tests need to reference a website or an API, ideally mock them.
There are nice packages, such as betamax_ and vcrpy_ that make it
trivial to record interactions with a remote server and reproduce them
locally — i.e. make it possible to run an "online" test suite offline.

If you need to work against a specific kind of server, consider using a
dedicated test server.  There are packages such as
pytest-localftpserver_ that make it easy to run a local FTP server and
test your package against it.  However, please *do not use Docker for
that*.  Docker generally requires root privileges and downloading large
machine images — it makes Internet use even worse.


Requiring containers (e.g. Docker) for testing
==============================================

A special case of the above are test suites that require access
to a working Docker daemon or a similar container system.  For example,
aiomcache uses Docker to start memcached in a container [#AIOMCACHE]_.

While using Docker is often convenient, it causes a few important
problems.  Firstly, it requires the test suite to have access
to a Docker daemon which poses an important security risk (test suites
are normally run using a dedicated user in Gentoo).  Secondly,
the daemon needs to download (potentially large) images from
the Internet, effectively implicating all the Internet access problems.

Should you decide to use Docker in your test suite, please make sure
to make it entirely optional.  If your tests require a certain server,
please either include an option to provide the executable locally
or to start it externally and let the user provide connection
parameters.


Fragile tests and timeouts
==========================

Some tests can be really fragile to the system load.  These tests tend
to pass on CI (but not always!) when the hardware running them is
relatively fast and not heavily loaded.  However, when they are run
on real Gentoo systems that are sometimes heavily loaded with other
builds or test suites, or are running low-end hardware like our Alpha
qr HPPA boxes, they start failing unpredictably.

The simplest example are tests that are running with short timeouts or
narrow timing assumptions.  The extreme example of this are tests that
verify that a particular routine is "fast enough".  For example, Gentoo
is skipping speed tests in aesara because they can't reliably pass
on busy systems [#AESARA]_.

In some cases, these limitations may be non-obvious at first.  For
example, priority used to fail due to "unreliable test timings" coming
from hypothesis [#PRIORITY]_.

When designing your test suite, please bear in mind that it may be run
on systems that are under heavy load, and possibly much weaker than
an average PC.  Be generous in timeout values, or at least provide
the ability to override (ideally "multiply") them.  If you really need
to include speed tests, please either make them opt-in or at least make
it easy to opt out of them.


Unconditional test dependencies
===============================

Some packages feature a number of optional dependencies.  Unfortunately,
sometimes what is an optional dependency at runtime becomes
an obligatory dependency for the test suite.  While in general we want
to run as many tests as possible, it is not always feasible for us
to maintain a large number of extra test dependencies, in order to run
a minor part of the test suite.

In extreme cases these additional dependencies may even make it
impossible to run the test suite on certain architectures.  For example,
the greenlet package supports only a handful of platforms [#GREENLET]_.
If the test suite requires it, it cannot be run on any other platform.

Ideally, please make non-essential test dependencies optional.  pytest
provides a convenient `pytest.importorskip()`_ function that can be used
to automatically skip tests when an import fails.

If a test dependency is required by an important subset of tests, yet it
is problematic, please at least scoping the imports so that it is
possible to deselect the tests requiring it.  For example, pip scopes
cryptography imports to make the tests requiring them skippable
(if the relevant symbols were imported globally in conftest, the entire
test suite would require that package) [#PIP]_.


Package quality checks
======================

In the opening paragraphs, I have pointed out that one of the goals
of upstream testing is ensuring that the package meets set quality
standards.  However, this is not necessarily a critical goal for
downstream testing.  After all, we aren't modifying the package code
in any way, merely shipping it in its current (or historical) form.

A few examples of what could qualify as quality checks are:

- code coverage checks (e.g. using pytest-cov_)
- linting (black_, pycodestyle_, pydocstyle_, pyflakes_, pylint_)
- type checking (mypy_)
- benchmarks (pytest-benchmark_)
- turning warnings into errors, i.e. ``-Werror``

Integrating these checks directly into the test suite could cause
surprising problems.  In the best case, they could unnecessarily slow
downstream testing down and introduce unnecessary dependencies.
In the worst case, they could cause the test suite to start failing over
time as the behavior of the used tools (and the quality standards they
adhere to) change.

For example, in the pydantic ebuild Gentoo skips mypy testing because it
has regressed multiple times after upgrading mypy to a newer version
[#PYDANTIC].  While using correct types is important and technically
the check could find valid bugs in code, more often than not it finds
minor issues that do not require patching downstream.

It is only too common for packages in a variety of programming languages
to start failing due to ``-Werror`` or an equivalent option.
In the case of C, it could be due to using a different compiler
or platform than was originally tested.  In the case of Python, these
are often deprecation warnings coming from dependent packages
or the Python interpreter itself.  Again, while some of them point
to valid bugs, most of them do not require immediate patching and only
cause unnecessary build and/or test failures.

A problem specific to pytest plugins is that some of them require
additional command-line options when used in the test suite.
For example, pytest-cov is configured by passing ``--cov*`` options
[#PYTEST-COV-CONFIG]_.  If these options are forced via ``addopts``
configuration variable, pytest throws an error if pytest-cov is not
installed (because it doesn't recognize the options).  As a result,
the test suite ends up requiring pytest-cov unconditionally!  That said,
this isn't a very big deal since we can strip these options easily.

If you'd like to run quality checks as part of your process, please
do so by all means.  However, please consider integrating them in such
a way as to make them entirely optional.  They could either be run
outside the test suite entirely, or integrated into it in an opt-in
or opt-out basis.

Rather than putting all options specific to pytest plugins
in ``addopts`` unconditionally, consider either passing them
externally in your CI configuration (e.g. calling ``pytest -Werror
--cov …`` — i.e. an opt-in solution) or using pytest-enabler_
to pass the relevant options only if the specified plugin is installed
(an opt-out solution).


Assuming -Werror, catching warnings as exceptions
=================================================

A surprisingly common side effect of running Python test suites using
``-Werror`` is catching warnings as exceptions.  To avoid the quality
check problems described in the previous section, Gentoo runs test
suites with ``-Wdefault`` instead.  As a result, the warning is never
turned into an exception, the test does not catch anything and it fails.

When you intend to check whether a warning is issued, use the method
appropriate to catch warnings — e.g. `unittest.TestCase.assertWarns()`_
or `pytest.warns()`_.  The fix is usually trivial, see e.g. the fix
in pydantic [#PYDANTIC-WARN]_.


Precision problems and other kinds of platform dependency
=========================================================

Floating-point arithmetic is hard.  There are numerous articles covering
its pitfalls, including `Floating Point Arithmetic: Issues
and Limitations`_ in Python documentation (and the links therein).
As a rule of thumb, you shouldn't assume that:

1. any operation will give the "obvious" result (e.g. 0.1 + 0.2 ≠ 0.3),

2. two mathematically equivalent operations will give the same result
   ([0.1 + 0.2] + 0.3 ≠ 0.1 + [0.2 + 0.3]),

3. a printed result will yield the same number when typed back.

Unsurprisingly, occasionally we see a test suite that fails
on a specific machine because the floating-point arithmetic gave
a different result than on the system used to run CI.  This doesn't even
have to be an exotic architecture — only recently I've found out that
test_sum_function in elementpath fails with Python 3.12 on my amd64
system (while it passes upstream) [#ELEMENTPATH]_.

Floating-point precision problems aren't the only category of
portability problems test suites face.  Besides architecture, test
suites can fail due to insufficient memory, operating system
differences, underlying filesystem (e.g. jupyter-server-fileid
has some test failures on tmpfs [#JUPYTER-SERVER-FILEID]_), missing
hardware devices and so on.

Sometimes these test failures are inevitable.  For example, we are
maintaining a large patch to skip failing tests in psutil because many
of the tests are making assumptions that don't hold on the variety
of Gentoo systems [#PSUTIL]_.  Another extreme example is our patch
increasing tolerances in matplotlib test suite that covers both
architecture differences and mismatches due to different dependency
versions [#MATPLOTLIB]_.

In general, please try to make your tests portable.  If you work with
floating-point numbers, prefer inequality comparisons over equality,
or use approximate equality comparisons
(e.g.  `unittest.TestCase.assertAlmostEqual()`_, `pytest.approx()`_) ­—
and be prepared that someone might report that the tolerance is too
small for their hardware.

If your test require specific platform features, try to detect whether
they're available and either skip the relevant tests or try to give
an explanatory error.  Prefer mocking system interfaces when feasible.

Be mindful of hardware access.  Your users may run your test suite using
their regular user.  The last thing you want is to scare them with
windows popping up in the middle of the test suite xvfbwrapper_
to the rescue!) or playing loud sounds via their speakers.


Missing test files, using git repository
========================================

Many packages do not include the complete set of files needed to run
tests in their source distributions (archives uploaded to PyPI).
In some cases this is intentional, in other cases it is accidental —
often going unnoticed simply because both the CI and developers run
tests against a git checkout.

While technically downstreams can often use an autogenerated git archive
(when the source hosting used provides such a feature), official
distributions are preferable since the former tarballs are not
guaranteed to be stable.  Furthermore, in case of some packages
the official source distributions include additional generated files.
For example, jupyter-server uses node.js scripts to build CSS files
[#JUPYTER-SERVER].  The PyPI sdist includes these files, and makes it
possible for Gentoo to avoid having to make the npm horror work somehow.

A special case are test suites that actually require a git checkout
to work.  Probably the most extreme case is GitPython — the package uses
its own repository as a test fixture, and therefore Gentoo needs
to redistribute GitPython and its submodules as git bundles
[#GITPYTHON]_.

Ideally, please include all the test files in source distributions.
This makes it possible for downstream distributors and users to run
tests against the exact same sources they are using to install the
package.  It can also be a good idea to build a sdist archive, unpack it
and run the tests inside the unpacked contents as part of CI.


Home directory use, config leakage
==================================

Another case worth mentioning are test suites that (often directly,
e.g.  via spawned tools) write into the user's home directory.  This is
technically not a problem for distribution testing, as we
unconditionally provide a temporary directory as ``HOME`` but it
affects starting the tests as a regular user.

The results can vary from package to package.  They can range from
packages leaving their own configuration files when they weren't
actually used by the user to very large caches (pre-commit can clone a
dozen large repositories and leave them in your ``~/.cache`` forever!).
They can also be as surprising as e.g. the test suite appending commands
to your shell history.

A somewhat similar problem are test suites being affected by different
aspects of system configuration.  These could be configuration files
from the home directory of the user, system configuration files,
environment variables or even the kernel configuration.  To list just
a few examples: nox's test suite fails if NO_COLOR is set in the test
environment [#NOX]_.  Some packages started failing due to readline
introducing the "bracketed paste" feature, and therefore we are
disabling bracketed-paste explicitly in ebuilds [#PEXPECT]_.  It isn't
uncommon for packages to fail due to the system using a different locale
or timezone than the CI environment.

Unfortunately, there is no trivial solution to these problems.  While
it may be tempting to try to isolate the test run as much as possible
(e.g.  by stripping most of the environment variables), removing too
much can also cause issues and surprising behavior.  Just to list one
example not strictly related to Python, stripping too much could remove
ccache or distcc-related control variables.

If your test suite may write into the home directory, it is generally
a good idea to override ``HOME`` with a temporary directory instead.
Many tools have command-line switches and environment variables
to disable or override system configuration.  Locale and timezone
settings can also be effected via environment variables (e.g. setting
``TZ=UTC``).  Known-bad environment variables can be stripped from
the test environment but please make sure to scope the stripping right.
For example, ``NO_COLOR`` should still be respected by the test runner
itself.


Requiring specific locales
==========================

A very special case of test problems are locale problems.  Many projects
are actually become aware of them, one way or another.  Unfortunately,
they are often solved via requiring a specific locale, usually
``en_US.UTF-8`` which is not a good solution either.  Some projects also
test with a variety of locale, e.g. agate uses German and French locales
for testing [#AGATE]_.

Gentoo is probably quite special here as unlike many other Linux
distributions, we do not default to building all locales or even
a "common subset" of them.  It is perfectly valid for a Gentoo system
to have only a "C" locale, and possibly a single very specific locale
(e.g.  ``pl_PL.UTF-8``).  As a result, tests assuming or explicitly
using ``en_US.UTF-8`` could fail.

A curious case worth mentioning is that BSD libc is less lenient
on locale strings than glibc is.  natsort project used to assume that
FreeBSD locale support is broken while they were incorrectly passing
``en_US.UTF8`` as locale instead of ``en_US.UTF-8`` [#NATSORT]_.

Ideally, make your test suite locale-independent.  If you need to rely
on locale-specific behavior, ideally use the ``C.UTF-8`` locale.  If you
need to support legacy systems that do not feature it, you can either
use the "C" locale, try to find a supported UTF-8 locale, or combine
both (e.g. "C" for reliable ``LC_COLLATE``, a UTF-8 locale for
``LC_CTYPE``).  If you need to test behavior on very specific locales,
please assume that they may not exist on a specific system and skip
the relevant tests if they are missing.


Fuzzing as a part of the test suite
===================================

Fuzz testing means testing the package's behavior against randomized
input.  Fuzzing can sometimes find non-obvious bugs.  However, it is
equally likely to be time-consuming and not produce anything new.
It also makes the test suite somewhat unpredictable, potentially making
it fail on one run and pass on another.

Gentoo doesn't follow a single rule with regards to fuzzer-based tests.
In general, if they are part of the normal test run, we leave them be.
However, if they are time consuming or otherwise problematic,
and the relevant functionality is covered by other tests, we may
deselect them.

Please include static tests for at least the few baseline inputs.
If you're including fuzzing as a part of the default test run, please
bear in mind not to make them too time consuming and make it easy
to deselect them.  If they require additional dependencies (such as
hypothesis_), please confine them to a separate file to make it possible
to avoid the dependency when they are being skipped.


Installing tests and test-related artifacts
===========================================

There is no single agreement on whether tests should be installed along
with the package or not.  Installing them enables the user to run
the test suite afterwards, especially if the package manager used didn't
support running tests.  The usual counterargument is that they take up
space.

Gentoo normally respects upstream decision in this regard.  After all,
we support running the test suite while the package is being built,
so post-install testing is not critical to us.

However, we do intervene if a top-level "test" or "tests" package is
installed.  This violates namespacing and is bound to cause collisions
when two packages attempt to install the same file.  It is usually a bug
stemming from using setuptools' find_packages() function without
exclusion rules, or using poetry's include key incorrectly (while
I don't have an example regarding tests here, installing stray files
via include key is not uncommon) [#JUPYTER-PACKAGING]_
[#PYRATELIMITER]_.

A crossover case between installing the test suite and assuming
a disposable source tree is when running the test suite (or merely
enabling it) causes additional files to be installed.  These could
be cache files, test outputs, helper programs.  For example,
scikit-build leaves test packages installed in site-packages
[#SCIKIT-BUILD]_.

Should you decide to install tests along with your package, please make
sure to put them in the correct namespace, e.g. inside your main
package.  Make sure that all files needed for them to pass are installed
as well, and that the test suite can find them.  Finally, make sure that
running it doesn't attempt to write into the installed package and
doesn't result in any leftover files.


References
==========

.. [#MKDOCSTRINGS] mkdocstrings:
   tests/test_handlers.py::test_extended_templates attempts to write
   into installed packages
   (https://github.com/mkdocstrings/mkdocstrings/issues/574)

.. [#STARLETTE] starlette:
   test_gzip_ignored_for_responses_with_encoding_set fails if brotlicffi
   is installed
   (https://github.com/encode/starlette/issues/1957)

.. [#PYCARES] test_query_class_chaos started failing
   (https://github.com/saghul/pycares/issues/187)

.. [#AIODNS] test_query_bad_chars started failing
   (https://github.com/saghul/aiodns/issues/107)

.. [#CRYPTOGRAPHY-VECTORS] cryptography-vectors: Test vectors
   for the cryptography package.
   (https://pypi.org/project/cryptography-vectors/)

.. [#PY-PDF-SAMPLE-FILES] sample-files: Files which can be used to test
   PDF readers
   (https://github.com/py-pdf/sample-files/)

.. [#AIOMCACHE] aiomcache; pytest configuration containing fixtures
   spawning memcached instance via Docker
   (https://github.com/aio-libs/aiomcache/blob/cea229ceb197a031bc85b3643bfe79df87626027/tests/conftest.py)

.. [#AESARA] aesara-2.9.0.ebuild: code skipping unreliable speed tests
   (https://gitweb.gentoo.org/repo/gentoo.git/tree/dev-python/aesara/aesara-2.9.0.ebuild?id=6df28d1b9ede2b415db5d80f323feb429bfb0779#n53)

.. [#PRIORITY] priority: Tests failure test_period_of_repetition
   with hypothesis-4.23.4 and pytest-4.4.1
   (https://github.com/python-hyper/priority/issues/136)

.. [#GREENLET] greenlet: platform directory containing support code
   for all platforms supported by the package
   (https://github.com/python-greenlet/greenlet/tree/616df6049cca1d94f783447ad164e331b3044ead/src/greenlet/platform)

.. [#PIP] pip: localized imports in a fixture to avoid unconditionally
   depending on the packages providing them
   (https://github.com/pypa/pip/blob/78ab4cf071fcbda8af83d6b03be57c27a7008da7/tests/conftest.py#L670-L673)

.. [#PYDANTIC] pydantic-1.10.9.ebuild: code skipping mypy tests
   (https://gitweb.gentoo.org/repo/gentoo.git/tree/dev-python/pydantic/pydantic-1.10.9.ebuild?id=bfa3a01822e04f236a845b33131a2e69eaf5bd7d#n67)

.. [#PYTEST-COV-CONFIG] pytest-cov: Configuration
   (https://pytest-cov.readthedocs.io/en/latest/config.html)

.. [#PYDANTIC-WARN] pydantic: Fix test_extra_used_as_enum
   to use pytest.warns()
   (https://github.com/pydantic/pydantic/commit/1c8b00be39317cb61b13caae4e45e29671f681b1)

.. [#ELEMENTPATH] elementpath:
   tests/test_xpath1_parser.py::LxmlXPath1ParserTest::test_sum_function
   fails on some systems
   (https://github.com/sissaschool/elementpath/issues/66)

.. [#JUPYTER-SERVER-FILEID] jupyter_server_fileid: tmpfs support
   (https://github.com/jupyter-server/jupyter_server_fileid/issues/58)

.. [#PSUTIL] psutil-5.9.5.ebuild: reference to a patch skipping
   unreliable tests
   (https://gitweb.gentoo.org/repo/gentoo.git/tree/dev-python/psutil/psutil-5.9.5.ebuild?id=053cdc93fd51768474df315eb75359a87366da7a#n18)

.. [#MATPLOTLIB] matplotlib-3.7.1-test.patch: a patch increasing test
   tolerance
   (https://gitweb.gentoo.org/repo/gentoo.git/tree/dev-python/matplotlib/files/matplotlib-3.7.1-test.patch?id=8e126e294a801a5f2995a832b1807fc17759ab83)

.. [#JUPYTER-SERVER] jupyter-server: build configuration that enables
   using npm-based builder
   (https://github.com/jupyter-server/jupyter_server/blob/main/pyproject.toml#L144)

.. [#GITPYTHON] GitPython-3.1.31.ebuild: ebuild using git bundles
   to appease the test suite
   (https://gitweb.gentoo.org/repo/gentoo.git/tree/dev-python/GitPython/GitPython-3.1.31.ebuild?id=bbc5f93ea0c2be8e1d4eda1fe173851bbbde660c)

.. [#NOX] nox: Tests fail when NO_COLOR=1 is set in the environment
   (https://github.com/wntrblm/nox/issues/708)

.. [#PEXPECT] pexpect-4.8.0_p20230402.ebuild: workaround to disable
   bracketed-paste in readline
   (https://gitweb.gentoo.org/repo/gentoo.git/tree/dev-python/pexpect/pexpect-4.8.0_p20230402.ebuild?id=b34695daa2abbf05f45ae45115047c0baf2f50c8#n38)

.. [#AGATE] agate: tests requiring de_DE.UTF-8 and fr_FR locales
   (https://github.com/wireservice/agate/blob/a5dc7bbaa0292c1cb8741b559d5dab618f5bd2f0/tests/test_data_types.py#L255-L281)

.. [#NATSORT] natsort: discussion regarding supposed locale.strxfrm()
   bug on FreeBSD
   (https://github.com/SethMMorton/natsort/commit/def59286fc678e366f13c1184fa3548bf4680144#r102852388)

.. [#JUPYTER-PACKAGING] jupyter-packaging: do not install tests
   as a top-level package
   (https://github.com/jupyter/jupyter-packaging/pull/135)

.. [#PYRATELIMITER] PyrateLimiter: Fix LICENSE file not to be installed
   into site-packages
   (https://github.com/vutran1710/PyrateLimiter/pull/97)

.. [#SCIKIT-BUILD] scikit-build: Tests try to install to system
   directory
   (https://github.com/scikit-build/scikit-build/issues/469)


.. _betamax: https://pypi.org/project/betamax/
.. _black: https://pypi.org/project/black/
.. _hypothesis: https://pypi.org/project/hypothesis/
.. _mypy: https://pypi.org/project/mypy/
.. _pycodestyle: https://pypi.org/project/pycodestyle/
.. _pydocstyle: https://pypi.org/project/pydocstyle/
.. _pyflakes: https://pypi.org/project/pyflakes/
.. _pylint: https://pypi.org/project/pylint/
.. _pytest-benchmark: https://pypi.org/project/pytest-benchmark/
.. _pytest-cov: https://pypi.org/project/pytest-cov/
.. _pytest-enabler: https://pypi.org/project/pytest-enabler/
.. _pytest-localftpserver: https://pypi.org/project/pytest-localftpserver/
.. _vcrpy: https://pypi.org/project/vcrpy/
.. _xvfbwrapper: https://pypi.org/project/xvfbwrapper/

.. _pytest.approx(): https://docs.pytest.org/en/latest/reference/reference.html#pytest.approx
.. _pytest.importorskip(): https://docs.pytest.org/en/6.2.x/skipping.html#skipping-on-a-missing-import-dependency
.. _pytest.warns(): https://docs.pytest.org/en/7.1.x/how-to/capture-warnings.html#warns
.. _unittest.TestCase.assertAlmostEqual(): https://docs.python.org/3.11/library/unittest.html#unittest.TestCase.assertAlmostEqual
.. _unittest.TestCase.assertWarns(): https://docs.python.org/3.11/library/unittest.html#unittest.TestCase.assertWarns


.. _`Floating Point Arithmetic: Issues and Limitations`:
   https://docs.python.org/3.11/tutorial/floatingpoint.html
