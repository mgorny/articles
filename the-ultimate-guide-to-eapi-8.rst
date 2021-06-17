============================
The ultimate guide to EAPI 8
============================
:Author: Michał Górny
:Date: 2021-06-16
:Version: 1.0
:Copyright: https://creativecommons.org/licenses/by/3.0/
:Specification: https://projects.gentoo.org/pms/8/pms.html


.. contents::


Preamble
========
Three years ago, I had the pleasure of announcing EAPI 7 as a major step
forward in our ebuild language.  It introduced preliminary support for
cross-compilation, it finally provided good replacements for the last
Portagisms in ebuilds and it included many small changes that made
ebuilds simpler.

Only a year and a half later, I have started working on the initial
EAPI 8 feature set.  Similarly to EAPI 6, EAPI 8 was supposed to focus
on small changes and improvements.  The two killer features listed
below were already proposed at the time.  I have prepared a few patches
to the specification, as well as the initial implementation
of the respective features for Portage.  Unfortunately, the work stalled
at the time.

Finally, as a result of surplus of free time last month, I was able
to resume the work.  Along with Ulrich Müller, we have quickly prepared
the EAPI 8 feature set, got it pre-approved, prepared the specification
and implemented all the features in Portage and pkgcore.  Last Sunday,
the Council has approved EAPI 8 and it's now ready for ``~arch`` use.

What's there in EAPI 8?  Well, for a start we have `install-time
dependencies (IDEPEND)`_ that fill a gap in our cross-compilation
design.  Then, `selective fetch/mirror restriction`_ make it easier
to combine proprietary and free distfiles in a single package.
`PROPERTIES and RESTRICT are now accumulated across eclasses`_ reducing
confusion for eclass writers.  There's `dosym -r to create relative
symlinks`_ conveniently from dynamic paths.  Plus bunch of other
improvements, updates and cleanups.


Killer features
===============

.. _IDEPEND:

Install-time dependencies (IDEPEND)
-----------------------------------
.. code-block:: bash

    EAPI=8
    inherit xdg-utils

    IDEPEND="dev-util/desktop-file-utils"

    pkg_postinst() {
        xdg_desktop_database_update
    }

    pkg_postrm() {
        xdg_desktop_database_update
    }

.. Note::

   TL;DR: ``IDEPEND`` specifies programs that you execute during
   ``pkg_preinst``, ``pkg_postinst``, ``pkg_prerm`` and ``pkg_postrm``.


Install-time dependencies are not a new idea.  It has been on the board
for quite some time already but we never had a compelling reason
to implement it.  The primary use case was to specify dependencies that
are needed during ``pkg_postinst`` phase and that can be unmerged
afterwards.  That's pretty much the same as ``RDEPEND``, except for
the unmerging part — and uninstalling a few tools did not seem a goal
justifying another dependency type.

EAPI 7 changed that.  With cross-compilation support, we have added
a new dependency type focused on the build host (``CBUILD``) tools —
``BDEPEND``.  Unfortunately, once we started porting ebuilds it has
finally occurred to me that we have missed one important use case.  We
could not run executables installed to the target system when
cross-compiling!  ``RDEPEND`` was no longer a suitable method of pulling
in tools for ``pkg_postinst``; and since ``BDEPEND`` is not used when
installing from a binary package, we needed something new.

This is where ``IDEPEND`` comes.  It is roughly to ``RDEPEND`` what
``BDEPEND`` is to ``DEPEND``.  Similarly to ``BDEPEND``, it specifies
packages that must be built for ``CBUILD`` triplet and installed into
``BROOT`` (and therefore queried using ``has_version -b``).  However,
alike ``RDEPEND``, it is used when the package is being merged rather
than built from source.  It is guaranteed to be satisfied throughout
``pkg_preinst`` and ``pkg_postinst``, and it can be uninstalled
afterwards.

In the example provided above, the ebuild needs to be update the icon
cache upon being installed or uninstalled.  By placing the respective
tool in ``IDEPEND``, the ebuild requests it to be available at the time
of ``pkg_postinst``.  When cross-compiling, the tool will be built
for ``CBUILD`` and therefore directly executable by the ebuild.

The dependency types table for EAPI 8 is presented below.

  ========================= ======= ======= ======== ======= =======
  Dependency type           BDEPEND IDEPEND DEPEND   RDEPEND PDEPEND
  ========================= ======= ======= ======== ======= =======
  Present at                build   install build    install n/a
  ------------------------- ------- ------- -------- ------- -------
  Binary compatible with    CBUILD          CHOST
  ------------------------- --------------- ------------------------
  Base unprefixed path      ``/``           SYSROOT  ROOT
  ------------------------- --------------- -------- ---------------
  Relevant offset-prefix    BROOT           EPREFIX
  ------------------------- --------------- ------------------------
  Path combined with prefix BROOT           ESYSROOT EROOT
  ------------------------- --------------- -------- ---------------
  PM query command option   ``-b``          ``-d``   ``-r``
  ========================= =============== ======== ===============


.. _fetch+:
.. _mirror+:

Selective fetch/mirror restriction
----------------------------------
.. code-block:: bash

  EAPI=8

  SRC_URI="
      ${P}.tgz
      fetch+https://example.com/${P}-patch-1.tgz
      mirror+https://example.com/${P}-fanstuff.tgz"

  RESTRICT="fetch"

.. Note::

   TL;DR: ``fetch+`` and ``mirror+`` prefixes can now be used
   in ``SRC_URI`` to lift respective restrictions.


Before EAPI 8, fetch and mirror restrictions applied globally.  That is,
if you needed to apply the respective restriction to at least one
distfile, you had to apply it to them all.  However, sometimes packages
used a combination of proprietary and free distfiles, the latter
including e.g. third party patches, artwork.  We had to mirror-restrict
them so far.

EAPI 8 brings the possibility of undoing fetch and mirror restriction
for individual files.  The rough idea is that you put a ``RESTRICT``
as before, then use special ``fetch+`` prefix to specify URLs that can
be fetched from, or ``mirror+`` prefix to reenable mirroring
of individual files.

Similarly to how ``fetch`` restriction implies ``mirror`` restriction,
``mirror`` override implies ``fetch`` override.  This might sound
confusing at first but when you think about it, it's perfectly logical.

The following table summarizes it.

  +----------+-----------------+------------+------------+
  | RESTRICT | URI prefix      | Fetching   | Mirroring  |
  +==========+=================+============+============+
  | (none)   | (any)           | allowed    | allowed    |
  +----------+-----------------+------------+------------+
  | mirror   | (none) / fetch+ | allowed    | prohibited |
  |          +-----------------+------------+------------+
  |          | mirror+         | allowed    | allowed    |
  +----------+-----------------+------------+------------+
  | fetch    | (none)          | prohibited | prohibited |
  |          +-----------------+------------+------------+
  |          | fetch+          | allowed    | prohibited |
  |          +-----------------+------------+------------+
  |          | mirror+         | allowed    | allowed    |
  +----------+-----------------+------------+------------+


Minor features
==============

.. _--datarootdir:
.. _--disable-static:

New econf-passed options
------------------------
The ``econf`` helper has been modified to pass two more options
to the configure script if the ``--help`` text indicates that they are
supported.  These are:

- ``--datarootdir="${EPREFIX}"/usr/share``
- ``--disable-static``

The former option defines the base directory that is used to determine
locations for system/desktop-specific data files, e.g. .desktop files
and various kinds of documentation.  This is necessary for ebuilds that
override ``--prefix``, as the default path is relative to it.

The latter option disables building static libraries by default.  This
is part of the ongoing effort to disable unconditional install of static
libraries.  [#QA-POLICY-STATIC]_


.. _PROPERTIES:
.. _RESTRICT:

PROPERTIES and RESTRICT are now accumulated across eclasses
-----------------------------------------------------------
Up to EAPI 7, ``PROPERTIES`` and ``RESTRICT`` were treated like
a regular bash variables when sourcing eclasses.  This meant that
if an eclass or an ebuild wanted to modify them, they had to explicitly
append to them, e.g. via ``+=``.  This was inconsistent with how some
other variables (but not all) were handled, and confusing to developers.
For example, consider the following snippet:

.. code-block:: bash

    EAPI=7

    inherit git-r3

    PROPERTIES+=" interactive"

Note how you needed to append to ``PROPERTIES`` set by git-r3 eclass,
otherwise the ebuild would have overwritten it.  In EAPI 8, you can
finally do the following instead:

.. code-block:: bash

    EAPI=8

    inherit git-r3

    PROPERTIES="interactive"

Now the complete list of metadata variables accumulated across eclasses
and ebuilds includes: ``IUSE``, ``REQUIRED_USE``, ``*DEPEND``,
``PROPERTIES``, ``RESTRICT``.  Variables that are not treated this way
are: ``EAPI``, ``HOMEPAGE``, ``SRC_URI``, ``LICENSE``, ``KEYWORDS``.
``EAPI`` and ``KEYWORDS`` are not supposed to be set in eclasses; as for
the others, we have decided that there is a valid use case for eclasses
providing default values and the ebuilds being able to override them.


.. _`dosym -r`:

dosym -r to create relative symlinks
------------------------------------
.. Note::

   TL;DR: ``-r`` now can be used to have dosym figure out the correct
   relative path from symlink to target.

We have been pushing for relative symlink targets for some time now,
as they are more reliable.  Consider the two following examples:

.. code-block:: bash

    dosym "${EPREFIX}"/usr/lib/frobnicate/frobnicate /usr/bin/frobnicate
    dosym ../lib/frobnicate/frobnicate /usr/bin/frobnicate

The first line creates a symlink using absolute path.  The big deal with
that is if you mount your Gentoo system in a subdirectory of your root
filesystem (e.g. for recovery), the symlink will point at the wrong
path!  Using relative symlinks (as demonstrated on the second line)
guarantees that the symlink will work independently of where
the filesystem is mounted.

There is also the less known fact that ``dosym`` has historically
prepended ``EPREFIX`` to the absolute paths passed as the first
argument, that had the side effect of making it impossible to create
symlinks pointing outside the offset prefix (e.g. into ``/dev`` or
``/proc``).  This is no longer the case, and now you need to prepend
``${EPREFIX}`` explicitly.  Using relative target avoids the problem
altogether and makes it less likely for you to forget about the prefix.

However, in some instances determining the relative path could be hard
or inconvenient.  This is especially the case if one (or both)
of the paths comes from an external tool.  To make it easier, EAPI 8
adds a new ``-r`` option that makes ``dosym`` create a relative symlink
to the specified path (similarly to ``ln -r``):

.. code-block:: bash

    dosym -r /usr/lib/frobnicate/frobnicate /usr/bin/frobnicate

Note that in this case, you do not pass ``${EPREFIX}``.  The helper
determines the *logical* relative path to the first argument and creates
the appropriate relative symlink.  It is very important here to
understand that this function does not handle physical paths, i.e. it
will work only if there are no directory symlinks along the way that
would result in ``..`` resolving to a different path.  For example,
the following will not work:

.. code-block:: bash

    dosym bar/foo /usr/lib/foo
    dosym -r /usr/lib/zomg /usr/lib/foo/zomg

The logical path from ``/usr/lib/foo/zomg`` to ``/usr/lib/zomg``
is ``../zomg``.  However, since ``/usr/lib/foo`` is actually a symlink
to ``/usr/lib/bar/foo``, ``/usr/lib/foo/..`` resolves
to ``/usr/lib/bar``.  If you need to account for such directory
symlinks, you need to specify the correct path explicitly:

.. code-block:: bash

    dosym bar/foo /usr/lib/foo
    dosym ../../zomg /usr/lib/foo/zomg


.. _usev:

usev now accepts a second argument
----------------------------------
The ``usev`` helper has been introduced to provide the historical
Portage behavior of outputting the USE flag name on match.  In EAPI 8,
we have decided to extend it, in order to provide an alternative
to three-argument ``usex`` with an empty third argument
(the two-argument variant uses a default of ``no`` for the false
branch).

In other words, the following two calls are now equivalent:

.. code-block:: bash

    $(usex foo --enable-foo '')
    $(usev foo --enable-foo)

This is particularly useful with custom build systems that accept
individual ``--enable`` or ``--disable`` options but not their
counterparts.

As a result, ``usev`` and ``usex`` can now be used to achieve all
the common (and less common) output needs as summarized in the following
table.

  ============================== ======== ========
  Variant                        True     False
  ============================== ======== ========
  usev *flag*                    *flag*
  usev *flag* *true*             *true*
  usex *flag*                    ``yes``  ``no``
  usex *flag* *true*             *true*   ``no``
  usex *flag* *true* *false*     *true*   *false*
  ============================== ======== ========


Other changes
=============

.. _updates:

Less strict naming rules for updates directory
----------------------------------------------
Up to EAPI 7, the files in ``profiles/updates`` directory had to follow
the naming scheme of ``nQ-yyyy``, indicating the quarter and the year
when they were added.  Such a choice of name had the side effect that
lexical sorting of filenames was quite inconvenient.

In EAPI 8, the naming requirement is removed.  Eventually, this will
permit us to switch to a more convenient scheme sorted by the year,
as well as split into different lengths of periods in the future, as we
see fit.

Note that this change actually requires changing the repository EAPI
(found in ``profiles/eapi``), so it will not really affect Gentoo for
the next two years.


.. _bash:

Bash 5.0 is now sanctioned
--------------------------
As of EAPI 8, the bash version used for ebuilds is changed from 4.2
to 5.0.  This means not only that ebuilds are now permitted to use
features provided by the new bash version but also the ``BASH_COMPAT``
value used for ebuild environment is updated, switching the shell
behavior.

The only really relevant difference in behavior is:

- Quotes are now removed from RHS argument of ``"${var/.../"..."}"``
  substitution:

  .. code-block:: bash

      var=foo
      echo "${var/foo/"bar"}"

  The above snippet yields ``"bar"`` in bash 4.2 but just ``bar``
  in 4.3+.

Potentially interesting new features include:

- Negative subscripts can now be used to set and unset array elements
  (bash 4.3+):

  .. code-block:: bash

      $ foo=( 1 2 3 )
      $ foo[-1]=4
      $ unset 'foo[-2]'
      $ declare -p foo
      declare -a foo=([0]="1" [2]="4")

- Nameref variables are introduced that work as references to other
  variables (4.3+):

  .. code-block:: bash

      $ foo=( 1 2 3 )
      $ declare -n bar=foo
      $ echo "${bar[@]}"
      1 2 3
      $ bar[0]=4
      $ echo "${foo[@]}"
      4 2 3
      $ declare -n baz=foo[1]
      $ echo "${baz}"
      2
      $ baz=100
      $ echo "${bar[@]}"
      4 100 3

- ``[[ -v ... ]]`` test operator can be used with array indices to test
  for array elements being set (4.3+).  The two following lines are now
  equivalent:

  .. code-block:: bash

      [[ -n ${foo[3]+1} ]]
      [[ -v foo[3] ]]

- ``mapfile`` (AKA ``readarray``) now accepts a delimiter via ``-d``,
  with a ``-t`` option to strip it from read data (bash 4.4+).  The two
  following solutions to grab output from ``find(1)`` are now
  equivalent:

  .. code-block:: bash

      # old solution
      local x files=()
      while read -d '' -r x; do
          files+=( "${x}" )
      done < <(find -print0)

      # new solution
      local files=()
      mapfile -d '' -t files < <(find -print0)

- A new set of transformations is available via ``${foo@...}`` parameter
  expansion (4.4+), e.g. to print a value with necessary quoting:

  .. code-block:: bash

      $ var="foo 'bar' baz"
      $ echo "${var@Q}"
      'foo '\''bar'\'' baz'

  For more details, see: ``info bash`` [#BASH-EXPANSION]_.

- ``local -`` can be used to limit single-letter (mangled via ``set``)
  shell option changes to the scope of the function, and restore them
  upon returning from it (4.4+).  The following two functions are now
  equivalent:

  .. code-block:: bash

      # old solution
      func() {
          local prev_shopt=$(shopt -p -o noglob)
          set -o noglob
          ${prev_shopt}
      }

      # new solution
      func() {
          local -
          set -o noglob
      }

The complete information on all changes and new features can be found
in the release notes [#BASH-NEWS]_.


.. _PATCHES:

PATCHES (src_prepare) variable no longer permits options
--------------------------------------------------------
The ``eapply`` invocation in the default ``src_prepare`` implementation
has been changed from the equivalent of:

.. code-block:: bash

    eapply "${PATCHES[@]}"

to:

.. code-block:: bash

    eapply -- "${PATCHES[@]}"

This ensures that all items in the ``PATCHES`` variable are treated
as path names.  As a side effect, it is no longer possible to specify
``patch`` options via the ``PATCHES`` variable.  Such hacks were never
used in ::gentoo but they have been spotted in user-contributed ebuilds.
The following will no longer work:

.. code-block:: bash

    PATCHES=( -p0 "${FILESDIR}"/${P}-foo.patch )

Instead, you will need to invoke ``eapply`` explicitly, i.e.:

.. code-block:: bash

    src_prepare() {
        eapply -p0 "${FILESDIR}"/${P}-foo.patch
        eapply_user
    }


.. _doconfd:
.. _doenvd:
.. _doheader:
.. _doinitd:

insopts and exeopts now apply to doins and doexe only
-----------------------------------------------------
We have noticed some inconsistency in how ``insopts`` and ``exeopts``
apply to various helpers in EAPI 7.  In particular, the majority
of helpers (e.g. ``dobin``, ``dodoc`` and so on) ignored the options
specified via these helpers but a few did not.

In EAPI 8, we have changed the behavior of the following helpers that
used to respect ``insopts`` or ``exeopts``:

- ``doconfd``
- ``doenvd``
- ``doheader``
- ``doinitd``

In EAPI 8, they always use the default options.  As a result,
``insopts`` now only affects ``doins``/``newins``, and ``exeopts`` only
affects ``doexe``/``newexe``.  Furthermore, ``diropts`` do not affect
the directories implicitly created by these helpers.


.. _working directory:

pkg_* phases now run in a dedicated empty directory
---------------------------------------------------
Before EAPI 8, the initial working directory was specified for ``src_*``
phases only.  For other phases (i.e. ``pkg_*`` phases), ebuilds were not
supposed to assume any particular directory.  In EAPI 8, these phases
are guaranteed to be started in a dedicated empty directory.

The problem with unspecified working directory dates back to 2016.
At the time, Portage defaulted to running these phases
in ``PORTAGE_PYM_PATH``, i.e. the directory containing Portage's Python
modules, usually the ``site-packages`` directory of the Python
interpreter used.  However, since Python's default search path starts
with the current directory, it meant that various Python scripts were
importing modules from this directory, possibly using modules
for the *wrong* Python interpreter.

This was originally reported as a ``pkg_preinst`` failure
in ``dev-python/packaging``.  Long story short, the reporter has been
using Python 2.7 as the system Python.  When the preinst phase run code
using Python 3, it mistakenly ended up loading packages from
the site-packages directory of Python 2.7, and this particular package
did not like it.  [#PACKAGING-PREINST-FAIL]_

Now, technically the fault was in the ebuild.  After all, PMS specified
that ebuilds must not rely upon any particular directory.  However,
it is rather unpractical to try to predict all the possible interactions
between tools run in these phases and arbitrary working directories.

At the time, Portage was modified to prefer using the temporary ``HOME``
directory created for the package, if available.  This pretty much meant
sweeping the problem under the rug.  EAPI 8 finally comes with
a permanent (we hope!) solution.

The idea of using an empty directory is pretty simple — if there are
no files in it, the risk of unexpected and hard to predict interactions
is minimalized.  It certainly is not a solution to all possible problems
but it should be good enough.


Bans and removals
=================

.. _hasq:
.. _hasv:
.. _useq:

hasq, hasv and useq functions have been banned
----------------------------------------------
If you look at some early Gentoo ebuilds, you can find little monsters
like the following:

.. code-block:: bash

    if [ -n "`use gnome`" ]
    then
        ./configure --host=${CHOST} --enable-gnome --disable perl --prefix=/opt/gnome --with-catgets
    else
        ./configure --host=${CHOST} --disable-gnome --disable-perl --prefix=/usr/X11R6 --with-catgets
    fi

This is because in its early days, the ``use`` helper did not return
a boolean value as exit status.  Instead, it printed the USE flag name
if it matched, and did not print anything if it did not.  So checking
for non-empty output was the thing.

In 2001, the boolean exit status was added to ``use`` but the output
remained.  In 2004, ``use`` was modified to output only when connected
to a tty.  However, that change was reverted shortly afterwards
and instead the quiet ``useq`` helper was added.  Then, the explicitly
verbose ``usev`` variant added, and finally ``use`` was made quiet
by default.  Same changes were applied to ``has``.

Fast forward to EAPI 7, we still have three variants of ``use``
and three variants of ``has``.  The base variant that is quiet,
the ``useq``/``hasq`` variant that is equivalent to the base variant
and the verbose ``usev``/``hasv`` variant.

In 2011, Portage already started warning about ``hasq`` and ``useq``
being deprecated.  After adding the second argumen to usev_ in EAPI 8,
we have noticed that we cannot do the same to ``hasv``, and at the same
time that it was not used a single time in ::gentoo.  Therefore, we have
decided to remove it and have picked up ``hasq`` and ``useq`` along with
it.


.. _unpack:

unpack removes support for 7-Zip, LHA and RAR formats
-----------------------------------------------------
In EAPI 8, we have decided to remove the support for the least commonly
used archive formats from ``unpack``.  This meant:

- 7-Zip (.7z) — used by 5 packages at the time of writing
- LHA (.lha, .lzh) — not used at all
- RAR (.rar) — used by 5 packages

Packages using these format for distfiles must now unpack them manually.
We recommend using ``unpacker.eclass`` for that.

Our goal is for PMS to specify the support for the most commonly used
archive formats, while everything else would be supported
via ``unpacker.eclass``.  The latter provides greater flexibility,
in particular making it possible to easily add support for alternative
unpackers (e.g. we could use 7-Zip to unpack RAR archives).


Retroactive changes
===================

.. _test_network:

PROPERTIES=test_network to ease reenabling tests requiring Internet
-------------------------------------------------------------------
Ideally, we'd want all tests to work just fine without accessing
the Internet, either via mocks or spawning local servers.
Unfortunately, not all packages do that and in the end,
Internet-accessing tests are sometimes the only tests we can get.  While
we do not want to run such tests by default (and we do want
``FEATURES=network-sandbox`` to protect us from uncontrolled Internet
access), it is valuable to be able to enable them in controlled
environments.

For this reason, we have decided to add a new ``PROPERTIES`` value
``test_network``.  It is supposed to be combined with ``RESTRICT=test``,
and it indicates that the tests are restricted precisely because they
need to access the Internet.

Now, old versions of package managers will just skip the tests because
of the test restriction.  However, new versions include a new
``ALLOW_TEST`` configuration variable (for ``make.conf``) that can
be used to elide test restriction.  If its value is set to ``network``,
then test restriction will be ignored on packages indicating
``network-test``.  This makes it an invaluable tool both for developers
and arch testers.

This feature was originally proposed for EAPI 8 as a new ``RESTRICT``
value.  However, we have decided that it will be cleaner and more
convenient to combine with ``RESTRICT=test`` and make an optional
extension for all EAPIs.


Cheat sheet / index
===================
The table following lists all the changes in a grep-for form that could
be used as a reference when upgrading ebuilds from EAPI 7 to EAPI 8.

  ==================== ====================================================
  Search term          Change
  ==================== ====================================================
  bash_                bash 5.0 is now sanctioned
  `--datarootdir`_     new econf-passed option
  `--disable-static`_  new econf-passed option
  doconfd_             no longer affected by ``insopts``
  doenvd_              no longer affected by ``insopts``
  doheader_            no longer affected by ``insopts``
  doinitd_             no longer affected by ``exeopts``
  `dosym -r`_          allows creating relative symlinks
  `fetch+`_            ``SRC_URI`` prefix to override fetch restriction
  hasq_                banned
  hasv_                banned
  IDEPEND_             new dependency type for ``pkg_postinst`` deps
  `mirror+`_           ``SRC_URI`` prefix to override mirror restriction
  PATCHES_             no longer permits specifying options (paths only)
  PROPERTIES_          now accumulated across eclasses
  RESTRICT_            now accumulated across eclasses
  test_network_        new ``PROPERTIES`` value for tests requiring Internet
  unpack_              no longer supports 7-Zip, LHA and RAR formats
  updates_             filenames no longer have to follow ``nQ-yyyy`` style
  useq_                banned
  usev_                accepts second argument to override output value
  `working directory`_ ``pkg_*`` phases now start in an empty directory
  ==================== ====================================================


References
==========
.. [#QA-POLICY-STATIC] Gentoo Policy Guide, Installation of static
   libraries
   (https://projects.gentoo.org/qa/policy-guide/installed-files.html#pg0302)

.. [#BASH-EXPANSION] Bash Reference Manual: Shell Parameter Expansion
   (https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)

.. [#BASH-NEWS] bash 5.0 (and earlier) release notes
   (https://git.savannah.gnu.org/cgit/bash.git/tree/NEWS?h=bash-5.0)

.. [#PACKAGING-PREINST-FAIL] dev-python/packaging with dev-python/future
   - pkg_preinst(): ImportError: This package should not be accessible
   on Python 3.
   (https://bugs.gentoo.org/574002)
