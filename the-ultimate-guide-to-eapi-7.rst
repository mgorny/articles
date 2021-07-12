============================
The ultimate guide to EAPI 7
============================
:Author: Michał Górny
:Date: 2018-05-03
:Version: 1.1
:Copyright: https://creativecommons.org/licenses/by/3.0/


.. contents::


Preamble
========
Back when EAPI 6 was approved and ready for deployment, I have written
a blog post entitled the Ultimate Guide to EAPI 6 [#EAPI6_GUIDE]_.
Now that EAPI 7 is ready, it is time to publish a similar guide to it.

Of all EAPIs approved so far, EAPI 7 brings the largest number
of changes.  It follows the path established by EAPI 6.  It focuses
on integrating features that are either commonly used or that can not
be properly implemented in eclasses, and removing those that are either
deemed unnecessary or too complex to support.  However,
the circumstances of its creation are entirely different.

EAPI 6 was more like a minor release.  It was formed around
the time when Portage development has been practically stalled.
It aimed to collect some old requests into an EAPI that would be easy to
implement by people with little knowledge of Portage codebase.
Therefore, the majority of features oscillated around bash parts of the
package manager.

EAPI 7 is closer to a proper major release.  It included some explicit
planning ahead of specification, and the specification has been mostly
completed even before the implementation work started.  We did not
initially skip features that were hard to implement, even though
the hardest of them were eventually postponed.

I will attempt to explain all the changes in EAPI 7 in this guide,
including the rationale and ebuild code examples.


Banned commands and removed variables
=====================================

.. _dohtml:

dohtml is banned
----------------
The ``dohtml`` function has been deprecated in EAPI 6 already, so it
should come as no surprise that EAPI 7 finally bans it.  The rationale
remains the same: it was overcomplex, confusing and frequently asked for
specification updates.

The replacement is ``dodoc -r``, combined with ``docinto`` whenever
necessary.  However, I should point out that there is no technical
reason to force ``html`` subdirectory for HTML files.  Packages with
a single HTML file or no non-HTML docs (sic!) can install them straight
to docdir.  Packages that have multiple HTML document trees can use
subdirectories named after what they contain.

.. code-block:: bash

    src_install() {
        # BAD: dohtml is banned
        dohtml -A txt -r foo/.

        # GOOD
        docinto html
        dodoc -r foo/.
    }


.. _dolib:
.. _libopts:

dolib and libopts are banned
----------------------------
EAPI 6 defined three ``dolib*`` functions: ``dolib.a``, ``dolib.so``
and plain ``dolib``.  By looking at the three names, you may come
to the wrong conclusion that ``dolib`` somehow wraps them both — but it
does not.  Turns out, it is just an alias for ``dolib.a``, combined
with support for ``libopts``.

Looking at the current state of Gentoo, developers prefer ``dolib.a``
and ``dolib.so`` with appropriately 4 and 5 times more calls of those
commands than of ``dolib``.  Furthermore, apparently many
of the ``dolib`` calls are wrongly used to install shared libraries.
The remaining uses are either static libraries or other non-library
files (for which ``dolib.a`` seemed inappropriate, I guess).
``libopts`` is not used at all.

In its basic form, ``dolib`` is redundant to ``dolib.a``, and confusing
to developers who assume it can also install shared libraries.
Technically, the ``libopts`` variant makes it possible to use ``dolib``
beyond what the two other helpers provide — however, there has been
no use case for that so far and it is unlikely there ever will be.
Even then, it can be fully satisfied with ``get_libdir`` combined
with ``doins``, so there is no reason to keep yet another helper.

Therefore, EAPI 7 bans ``dolib`` and ``libopts``. The two remaining
functions are replacements:

- ``dolib.so`` to install shared libraries, their symlinks and any other
  file that needs to be installed into libdir as ``+x``, and

- ``dolib.a`` to install static libraries and any other regular file
  to libdir.

.. code-block:: bash

    src_install() {
        # BAD: dolib is banned
        dolib libfoo.a foo.o
        # TWICE BAD: dolib was not meant to install shared libraries
        dolib libfoo.so libfoo.so.1

        # GOOD: dolib.a installs files -x
        dolib.a libfoo.a foo.o
        # GOOD: dolib.so install files +x
        dolib.so libfoo.so libfoo.so.1
    }


.. _ECLASSDIR:
.. _PORTDIR:

PORTDIR and ECLASSDIR are removed
---------------------------------
EAPI 6 has defined three variables that specifically referenced
locations inside the ebuild repository:

1. ``PORTDIR`` — top directory of the repository,

2. ``ECLASSDIR`` — its ``eclass`` subdirectory,

3. ``FILESDIR`` — the ``files`` subdirectory of the current package.

After a very long struggle, we were able to eliminate the uses
of the first two, and eventually remove them in EAPI 7.  The third one
was left but it can be easily implemented using a temporary directory
without having access to the actual repository.  Portage was modified
to use such a shadow directory.

The rationale is that the ``PORTDIR`` and ``ECLASSDIR`` variables were
pretty much fundamentally wrong design, and bypassed the package manager
in accessing the repository.  As a result, they were frequently abused,
e.g. to access ``files`` subdirectory of another package or store data
in ``ECLASSDIR``.

Those variables dated back to the concept of a single repository
with overlays.  The PMS attempted to fit that old concept into
the new multi-repo world.  This created a weird hybrid in which
both variables referenced an opaque concept of ‘master repository’.
While it worked most of the time, it was an odd fit — as it did not
necessarily reference the repository containing the ebuild or eclass
in question but — with some luck — the Gentoo repository, being
the final master and the source of abuse.

Furthermore, they also undesirably made ebuilds rely on very specific
format and contents of the repository.  Partial checkouts, full Manifest
coverage (with protection from using unverified files), more optimal
ebuild storage — ``PORTDIR`` stood in the way of it all.

As for replacements, there are none.  If whatever you needed doing
requires direct repository access, you were doing it wrong.  That said,
providing a way to access licenses was considered at a point.  However,
nobody has come up with a really good use case for it and it was
abandoned as unnecessary.


.. _DESTTREE:
.. _INSDESTTREE:

DESTTREE and INSDESTTREE are gone
---------------------------------
Those two were pretty much implementation details that inadvertently
made it to the variable list.  ``DESTTREE`` used to specify the ``into``
install prefix, while ``INSDESTTREE`` the ``insinto`` directory.
Historically, there were others like them but they have been
retroactively removed in the past.  Now we remove the two remaining
variables after replacing all their uses.

If you want to set the paths, call ``into`` and ``insinto`` directly.
If you need to limit their scope, put them in a subshell.

Getting the currently set path is unsupported.  If you're trying to
avoid repeating the same path multiple times, use a helper variable.
Or just repeat it for improved readability.

.. code-block:: bash

    # BAD: uses INSDESTTREE
    dofoo() {
        local INSDESTTREE=/usr/share/foo
        doins "${@}"
    }

    # GOOD: uses subshell
    dofoo() {
        (
            insinto /usr/share/foo
            doins "${@}"
        )
    }

    src_install() {
        insinto /usr/share/foo
        doins foo

        # BAD: uses INSDESTTREE
        dosym foo "${INSDESTTREE}"/bar
        # GOOD: uses full path
        dosym foo /usr/share/foo/bar
    }

    # GOOD: uses helper var
    src_install() {
        local mypath=/usr/share/foo

        insinto "${mypath}"
        doins foo

        dosym foo "${mypath}"/bar
    }


.. _desktop.eclass:
.. _eapi7-ver.eclass:
.. _epatch.eclass:
.. _estack.eclass:
.. _eutils.eclass:
.. _ltprune.eclass:
.. _preserve-libs.eclass:
.. _vcs-clean.eclass:

Related eclass changes
----------------------
As usual, I encourage developers to remove and ban obsolete APIs
of their eclasses at EAPI upgrade point.  This is the best way
of cleaning up stale stuff with minimal risk of breakage.

In EAPI 7, a few obsolete eclasses are banned:

- ``eapi7-ver.eclass`` — all functions included in EAPI 7
- ``epatch.eclass`` — replaced by EAPI 6 ``eapply`` function
- ``ltprune.eclass`` — obsoleted in favor of inline pruning
  (``find "${D}" -name '*.la' -delete || die``)
- ``versionator.eclass`` — replaced by EAPI 7 version functions
  (see also: `replacing versionator.eclass uses`_)

Additionally, ``eutils.eclass`` stops implicitly providing the functions
that were split out of it.  If you need one of the following functions,
you need to explicitly inherit the eclass providing them:

- ``desktop.eclass`` — ``make_desktop_entry``, ``make_session_desktop``,
  ``domenu``, ``doicon`` and their ``new*`` variants
- ``epatch.eclass`` — ``epatch`` (banned)
- ``estack.eclass`` — ``estack*``, ``evar*``, ``eshopts*``, ``eumask*``
- ``ltprune.eclass`` — ``prune_libtool_files`` (banned)
- ``preserve-libs.eclass`` — ``preserve_old_lib``
- ``vcs-clean.eclass`` — ``e*_clean``

Additionally, the implicit inherits of ``multilib.eclass``
and ``toolchain-funcs.eclass`` are removed.  Once you inherit
the correct split eclasses, please recheck whether you still need
``eutils``.


Improved cross-compilation support
==================================

Introduction
------------
Developers doing cross-compilation on Gentoo have requested a split
of build-time dependencies for quite some time already.  There has been
even an experimental ``5-hdepend`` EAPI at some point but all
the efforts were pretty much haphazard.

For EAPI 7, we finally managed to get the few relevant developers
to focus and establish a real plan on supporting cross-compilation.
Like Prefix, it is optional by design.  The behavior for package
managers not interested in the topic is clearly defined, and regular
developers can continue writing ebuilds without much regard
to the problem.  The developers wishing to support cross can now
modify the ebuilds without risking incompatibility between different
package managers.

The first step in designing this part of the specification was to
finally settle on consistent and unambiguous terminology.  To achieve
that, we decided to use the autotools triplet names.  This includes
the following three triplets:

1. ``CBUILD`` — the system used to build packages, i.e. the one running
   the cross-compiler.  This triplet is used to build executables that
   are run during the build.  When not cross-compiling, ``CBUILD`` is
   equal to ``CHOST``.

2. ``CHOST`` — the system that will be running the installed package.
   There is no guarantee that executables built for this triplet
   will run on the build machine.

3. ``CTARGET`` — only used when building some cross-toolchain tools,
   specifies the system for which the cross-toolchain is going to build.
   We can ignore it for the purpose of PMS.

Now that we have clear terms, I can proceed with explaining the changes.


.. _BDEPEND:
.. _DEPEND:

Build-time dependencies split into DEPEND and BDEPEND
-----------------------------------------------------
For the purposes of cross-compilation, it is useful to split build-time
dependencies into two groups:

1. Dependencies that need to be run during the build, and therefore
   must run on the system used to build packages (``CBUILD``). Those
   include toolchain, build system tooling (autotools, CMake), various
   language interpreters (Perl, Python), preprocessors (SWIG) and other
   tools (e.g. pkg-config).  Those are placed in ``BDEPEND`` now.

2. Dependencies that need to be compiled for the real system,
   and present for the toolchain to work.  Those mostly include
   libraries since the link editor needs to link to them.  Those
   remain as ``DEPEND``.

Without the split, a strict package manager would have to build all
packages twice.  With the split, we can save time and reduce the size
of cross-compiled system.

While the necessity of splitting dependencies was clearly agreed on,
there was lot of discussion on how to name the new variables.  Amongst
all possible variants, ``BDEPEND``/``DEPEND`` were chosen for two
reasons. Firstly, to avoid ambiguity in name (B goes for CBUILD,
while H could be confused between CHOST/host).  Secondly, because most
of the existing packages in ``DEPEND`` fit into the second group,
so leaving them in place follows the principle of smallest change
necessary.

.. code-block:: bash

    # CBUILD build-time dependencies
    BDEPEND="
        virtual/pkgconfig"
    # CHOST build-time dependencies (e.g. libraries)
    DEPEND="
        dev-libs/libfoo:="
    # Runtime dependencies
    RDEPEND="${DEPEND}
        app-misc/frobnicate"


.. _SYSROOT:
.. _ESYSROOT:

SYSROOT and ESYSROOT variables (for DEPEND)
-------------------------------------------
The concept of sysroot was pretty well-known among cross-compiler
users, and to some degree deployed as a user-defined environment
variable.  Starting with EAPI 7, sysroots are cleanly defined
and supported officially.

According to the EAPI 7 definition, ``SYSROOT`` is the location where
``DEPEND``-class packages are installed.  Like ``ROOT``, it comes with
no embedded ``EPREFIX`` and has an ``ESYSROOT`` variant with prefix
appended.  When ``SYSROOT`` is different from ``ROOT``, pure build time
dependencies (``DEPEND``) are installed to ``SYSROOT``, allowing users
to save space on the filesystem running the actual target.

.. Note::

   Originally, ``ESYSROOT`` used ``EPREFIX`` unconditionally.  However,
   the logic has been changed retroactively as described below.

It was unclear whether ``SYSROOT`` should embed the offset prefix
or not, and whether a different value of ``EPREFIX`` should be allowed
for ``SYSROOT``.  Eventually, we have decided to use the following
logic to keep things somewhat simple and working at the same time:

1. If ``SYSROOT`` is equal to ``ROOT``, then ``EPREFIX`` is used.
   Effectively, ``ESYSROOT`` is equal to ``EROOT``.

2. If ``SYSROOT`` is empty and ``ROOT`` is not empty, then ``BROOT``
   is used.  Effectively, ``ESYSROOT`` is equal to ``BROOT``.

3. Otherwise, no prefix is used and ``ESYSROOT`` is equal
   to ``SYSROOT``.

.. code-block:: bash

    src_configure() {
        # HACK: add include path missing upstream
        local -x CPPFLAGS="${CPPFLAGS} -I${ESYSROOT}/usr/include/foo"

        # variant getting prefixed path from an eclass
        local -x CPPFLAGS="${CPPFLAGS} -I${SYSROOT}$(get_foo_path)/foo-1.0"

        default
    }


.. _BROOT:

BROOT variable (for BDEPEND)
----------------------------
Since we have explicit path variables for ``DEPEND`` and ``RDEPEND``,
it only seemed reasonable to include one for ``BDEPEND`` as well
(``PDEPEND`` is irrelevant since it is not guaranteed to be installed
before ebuild finishes).  The ``BROOT`` (build-root) variable serves
that exact purpose.  Unlike the other two variables, it is the full path
including any prefix (which may be different than ``EPREFIX``).

The rationale for this is that there are valid cases for cross-
compilation with different prefixes.  An example is building packages
for a Gentoo Prefix on Android — we certainly do not want to be required
to use a Prefix system with a matching prefix to do that.

We have decided not to split this path into a separate ‘base path’
and prefix since there does not seem to be any specific need for that.
After all, the path is derived from the original build tool path which
were ``/`` or ``${EPREFIX}``, depending on the EAPI in use.  In this
case, we are allowing a separate prefix and the choice of name between
``BROOT`` and ``BPREFIX`` was purely arbitrary.

.. code-block:: bash

    src_configure() {
        # Call qmake from BDEPEND
        "${BROOT}"/usr/$(get_libdir)/qt5/bin/qmake . || die
    }


.. _econf:

New ./configure parameters in econf
-----------------------------------
To help with implementing the new logic, two sets of parameters
for configure scripts (via ``econf``) were considered: ``--build``
and ``--target`` options for cross-triplets, and ``--with-sysroot``
for sysroot.

The ``--build`` and ``--target`` are used to pass ``CBUILD``
and ``CTARGET`` respectively to the configure scripts.  Their presence
(or rather, values disjoint from ``--host``) enable the cross-\
compilation logic in configure.  Both of them were added retroactively
to all EAPIs, as being passed whenever the respective variable is not
empty.  This is because they were implemented this way in all three
package managers for a long time — in Portage since at least 2005, in
the other two since their inception.

The ``--with-sysroot`` option is specific to projects using libtool,
and overrides the sysroot used by libtool (obtained from the compiler).
It is passed in EAPI 7 if ``./configure --help`` indicats that such
an option is present (i.e. like all the other optional flags).


.. _best_version:
.. _has_version:

New options to has_version and best_version
-------------------------------------------
As part of the new dependency type and location logic, the options
to ``has_version`` and ``best_version`` needed to be updated.  EAPI 5
has already provided a ``--host-root`` option that caused the query to
apply to ‘host root’ instead of ``ROOT``.  However, we found that name
confusing and eventually decided to replace it with another layout.

As of EAPI 7, both of those functions optionally take a single short
option ``-b``, ``-d`` or ``-r`` that cause it to apply to the locations
of ``BDEPEND``, ``DEPEND`` and ``RDEPEND`` appropriately.  The default
is ``-r``.  Since those commands scan packages, the dependency type
names seemed most appropriate and unambiguous.

.. code-block:: bash

    src_configure() {
        # HACK: missing split tinfo awareness upstream
        has_version -d 'sys-libs/ncurses[tinfo]' &&
            local -x LIBS="${LIBS} -ltinfo"

        default
    }

    pkg_postinst() {
        if ! has_version -r 'app-misc/frobnicate'; then
            elog "You may want to install app-misc/frobnicate."
        fi
    }


Summary
-------
Finally, to help developers cope with all the logic, we have included
a neat table that summarizes all the relevant interfaces for different
dependency types.  It is included below for completeness.

  ========================= ======= =========== ================
  Dependency type           BDEPEND DEPEND      RDEPEND, PDEPEND
  ========================= ======= =========== ================
  Binary compatible with    CBUILD  CHOST       CHOST
  Base unprefixed path      ``/``   SYSROOT     ROOT
  Relevant offset-prefix    BROOT   (see above) EPREFIX
  Path combined with prefix BROOT   ESYSROOT    EROOT
  PM query command option   ``-b``  ``-d``      ``-r``
  ========================= ======= =========== ================


Version manipulation and comparison commands
============================================

Introduction
------------
One of the goals for EAPI 7 was to integrate commonly used commands
for version manipulation and comparison.  Those functions used
to be provided by ``versionator.eclass``.  However, this eclass used
to provide 15 different functions and that would be a lot for a new
EAPI.  Moreover, many of the functions were redundant, some of them used
very rarely and all of them were suboptimal.  Therefore, we decided
to work on a new concept instead.

We have established how various functions are used, and prepared a new
EAPI consisting of three functions that can wholly replace almost all
the real uses of ``versionator.eclass``.  Those are: 

- ``ver_cut`` to obtain substrings of a version string
- ``ver_rs`` to replace separators in a version string
- ``ver_test`` to compare two versions

The first two functions work using a new, flexible version syntax
that can be used to operate on Gentoo versions as well as on upstream
versions.  The third provides fully PMS-compliant version comparison
routines with a friendly usage resembling the shell ``test`` builtin.

To provide some real-life testing, ``eapi7-ver.eclass`` was written
providing the reference implementation for previous EAPIs.


Version strings (for manipulation)
----------------------------------
The ``ver_cut`` and ``ver_rs`` functions use simplified version rules
that are better suited for various manipulations than the standard rules
used for ebuild versions.  For the purpose of manipulation, the version
is split into series of version components delimited by (possible empty)
version separators.

The split is explained nicely by the ``eapi7-ver.eclass`` documentation:

  A version component can either consist purely of digits (``[0-9]+``)
  or purely of uppercase and lowercase letters (``[A-Za-z]+``).
  A version separator is either a string of any other characters
  (``[^A-Za-z0-9]+``), or it occurs at the transition between a sequence
  of letters and a sequence of digits, or vice versa.  In the latter
  case, the version separator is an empty string.

  The version is processed left-to-right, and each successive component
  is assigned numbers starting with 1.  The components are either split
  on version separators or on boundaries between digits and letters
  (in which case the separator between the components is empty).
  Version separators are assigned numbers starting with 1 (for
  the separator between 1st and 2nd components).  As a special case,
  if the version string starts with a separator, it is assigned index 0.

Examples:

  =============== = == = == = = = ===== = =
  Type            s c  s c  s c s c     s c
  --------------- - -- - -- - - - ----- - -
  Index           0 1  1 2  2 3 3 4     4 5
  =============== = == = == = = = ===== = =
  ``1.2.3``         1  . 2  . 3
  ``1.2b_alpha4``   1  . 2    b _ alpha   4
  ``2Ab9s``         2    Ab   9   s
  ``A.4.``          A  . 4  .
  ``.11.``        . 11 .
  =============== = == = == = = = ===== = =


.. _ver_cut:

Obtaining version substring (ver_cut)
-------------------------------------
Usage: ``ver_cut <range> [<version>]``

The ``ver_cut`` function is provided to obtain a substring
of the original version string.  It is somewhat inspired
by the coreutils ``cut`` utility.  It takes the range to cut
(``<start>[-[<end>]]``) and optionally a version to use (defaulting
to ``PV`` when unspecified), and returns the appropriate portion
of version components and the separators between them.

The function accepts ranges going past the version string.  If it spans
before the first version component (i.e. starts at zero), it includes
the separator zero.  If it spans past the last component, it includes
the trailing separator.  If it does not include any existing components,
it outputs an empty string.

Examples (``_`` is used for alignment, it is not part of the output):

  ===== ========= ========= ======== ==========
  Range ``1.2.3`` ``2Ab9s`` ``A.4.`` ``.11.2.``
  ===== ========= ========= ======== ==========
  0     ``_____`` ``_____`` ``____`` ``______``
  0-1   ``1____`` ``2____`` ``A___`` ``.11___``
  1     ``1____`` ``2____`` ``A___`` ``_11___``
  1-    ``1.2.3`` ``2Ab9s`` ``A.4.`` ``_11.2.``
  1-2   ``1.2__`` ``2Ab__`` ``A.4_`` ``_11.2_``
  1-3   ``1.2.3`` ``2Ab9_`` ``A.4.`` ``_11.2.``
  2     ``__2__`` ``_Ab__`` ``__4_`` ``____2_``
  2-3   ``__2.3`` ``_Ab9_`` ``_4._`` ``__2.__``
  3-    ``____3`` ``___9_`` ``____`` ``______``
  4-    ``_____`` ``____s`` ``____`` ``______``
  ===== ========= ========= ======== ==========

.. code-block:: bash

    # e.g.   https://example.com/foo/download/1.2/foo-1.2.3.tar.gz
    SRC_URI="https://example.com/foo/download/$(ver_cut 1-2)/${P}.tar.gz"


.. _ver_rs:

Replacing version separators (ver_rs)
-------------------------------------
Usage: ``ver_rs <range> <repl> [<range> <repl>...] [<version>]``

The ``ver_rs`` function is provided to perform a separator replacement
in the version string.  It takes one or more range-replacement pairs,
optionally followed by a version to use (again, defaulting to ``PV``),
and outputs the version after performing the specified replacements.

Parameters are processed left to right, and each separator (even empty!)
matching indexes specified in the range is replaced with a copy
of replacement.  Note that this function replaces zeroth or trailing
version separator only if it non-empty, i.e. it does not prepend
or append a version separator.

The replacement string can be empty to strip the version separators.
When multiple ranges are used, the indexes do not change between
replacements (i.e. stripping a version separator does not combine
components until the function returns).

Examples (replacement being ``#``, spaces added only for alignment,
they do not represent parts of version string):

  ===== ========= ============ ======== ==========
  Range ``1.2.3`` ``2 Ab 9 s`` ``A.4.`` ``.11.2.``
  ===== ========= ============ ======== ==========
  0     ``1.2.3`` ``2 Ab 9 s`` ``A.4.`` ``#11.2.``
  0-1   ``1#2.3`` ``2#Ab 9 s`` ``A#4.`` ``#11#2.``
  1     ``1#2.3`` ``2#Ab 9 s`` ``A#4.`` ``.11#2.``
  1-    ``1#2#3`` ``2#Ab#9#s`` ``A#4#`` ``.11#2#``
  1-2   ``1#2#3`` ``2#Ab#9 s`` ``A#4#`` ``.11#2#``
  2     ``1.2#3`` ``2 Ab#9 s`` ``A.4#`` ``.11.2#``
  2-3   ``1.2#3`` ``2 Ab#9#s`` ``A.4#`` ``.11.2#``
  3     ``1.2.3`` ``2 Ab 9#s`` ``A.4.`` ``.11.2.``
  ===== ========= ============ ======== ==========

.. code-block:: bash

    # 1.2.3 -> 1.2-3
    MY_P=${PN}-$(ver_rs 2 -)

    
.. _ver_test:

Version comparison (ver_test)
-----------------------------
Usage: ``ver_test [<v1>] <op> <v2>``

Finally, the ``ver_test`` function tests two versions for the relation
specified as operator between them.  The first version is optional,
and defaults to ``PVR``.  If it is not specified, the operator shifts
to first position.

The following operators (inspired by shell) are supported:

- ``-gt`` — *v1* is greater than *v2*
- ``-ge`` — *v1* is greater than or equal to *v2*
- ``-eq`` — *v1* is equal to *v2*
- ``-ne`` — *v1* is not equal to *v2*
- ``-le`` — *v1* is less than or equal to *v2*
- ``-lt`` — *v1* is less than *v2*

We have decided to use the ‘verbose’ operator names instead of literal
``<`` and ``>`` as the latter would require being explicitly escaped
in bash.

Example:

.. code-block:: bash

    pkg_postinst() {
        local v
        for v in ${REPLACING_VERSIONS}; do
            if ver_test "${v}" -lt 1.3; then
                elog "Some verbose upgrade message for <1.3 users"
            fi
        done
    }


.. _versionator.eclass:

Replacing versionator.eclass uses
---------------------------------
As mentioned before, the new three commands provide replacements
for most of the ``versionator.eclass`` functions.  The table below
lists possible replacements for all of them, ordered by approximate
frequency of use (based on grep done on 2018-02-18).

Please note that some of those replacements are hacky.  Usually, you
won't be doing direct replacements of ``versionator.eclass`` functions,
and rather considering how to solve the problem best with the new
functions.

  ==================================== ==== ============================
  Function                             Uses Possible replacement
  ==================================== ==== ============================
  ``get_version_component_range``      398  ``ver_cut ...``
  ``replace_version_separator RANGE``  123  ``ver_rs ...``
  ``replace_all_version_separators``   62   ``ver_rs 1- ...``
  ``get_major_version``                57   ``ver_cut 1``
  ``version_is_at_least``              56   ``ver_test ... -ge ...``
  ``delete_all_version_separators``    24   ``ver_rs 1- ''``
  ``delete_version_separator``         12   ``ver_rs ... ''``
  ``get_version_components``           8    ``ver_rs 1- ' '``
  ``get_version_component_count``      7    length of above as array
  ``version_format_string``            6    (none)
  ``version_compare``                  4    ``ver_test ...``
  ``get_last_version_component_index`` 4    like array length above - 1
  ``delete_version_separator CHAR``    4    ``${PV//.../}``
  ``get_all_version_components``       3    (none)
  ``get_after_major_version``          3    ``ver_cut 2-``
  ``replace_version_separator CHAR``   3    ``${PV//.../...}``
  ``version_sort``                     1    (none)
  ==================================== ==== ============================


Other new features and commands
===============================

.. _eqawarn:

eqawarn to print warnings for developers
----------------------------------------
Usage: ``eqawarn <message>``

After years of being a Portage-specific extension with fallback
implementation in ``eutils.eclass``, EAPI 7 finally brings ``eqawarn``.
This an additional variant of output function that is specifically
aimed at ebuild developers, and may not be shown to regular users
(depending on package manager configuration).

The main use case is providing warnings about incorrect eclass use,
or deprecated eclass functions.  However, most of the Gentoo developers
know that already — all that really needs to be said, you no longer
have to ``inherit eutils`` for that.

.. code-block:: bash

    dodeprecated() {
        eqawarn "Oh no, dodeprecated function is deprecated!"
        # ...
    }


.. _ENV_UNSET:

Environment variable filtering (ENV_UNSET)
------------------------------------------
The next useful feature brought by EAPI 7 is environment variable
unsetting, or ``ENV_UNSET`` profile variable.  As the name suggests,
it is used to prevent variables from leaking from the calling
environment.  All variables listed there will be explicitly unset
before the ebuild is sourced.

The main use case is preventing the calling environment from breaking
the package build process.  The PMS used to explicitly list a number
of problematic variables to be filtered already.  However, this list
is outdated for some time already, and does not include e.g. ``XDG_*``
path variables which affect the build of many packages.  Instead of
constantly pursuing the correct variable list in the PMS, we have
decided to let profiles specify them.

There was a lot of debate whether the behavior should be a blacklist
or a whitelist.  However, the latter has seen a lot of opposition due to
requiring more work to pursue all the variables that user is actually
allowed to set.  Therefore, we have decided to implement blacklist
for the time being.

.. code-block:: bash

    # Unset XDG_* directories to prevent them from breaking stuff
    ENV_UNSET="XDG_DATA_HOME XDG_CONFIG_HOME XDG_DATA_DIRS
        XDG_CONFIG_DIRS XDG_CACHE_HOME XDG_RUNTIME_DIR"


.. _dostrip:

Controllable stripping (dostrip)
--------------------------------
Usage: ``dostrip [-x] <path>...``

The previous EAPIs used to provide only a single switch to disable
stripping in the whole package (via ``RESTRICT=strip``).  While this
solved the problem, we have some packages where stripping is only
problematic for one or two files, and disabling it for the whole package
is undesirable.  For this reason, EAPI 7 brings support for controllable
stripping.

The concept was closely based on controllable compression.  By default,
stripping is enabled for all files and ``dostrip -x`` can be used
to disable stripping per-path.  Alternatively, when ``RESTRICT=strip``
is used, ``dostrip`` can be used to select files to strip.

.. code-block:: bash

    src_install() {
        default

        # you shall not strip!
        dostrip -x /usr/$(get_libdir)/very_important.o
    }


.. _eapply:
.. _eapply_user:
.. _patch:

GNU patch 2.7 compatibility
---------------------------
EAPI 7 requires the provided ``patch`` command to be compatible
with GNU patch 2.7 or newer.  The most important change, after the NEWS
file:

  * Support for most features of the "diff --git" format, including
    renames and copies, permission changes, and symlink diffs.  Binary
    diffs are not supported yet; patch will complain and skip them.


Other behavior changes
======================

.. _D:
.. _ED:
.. _ROOT:
.. _EROOT:

D, ED, ROOT, EROOT no longer have a trailing slash
--------------------------------------------------
The previous EAPIs specified that the four path variables: ``D``,
``ED``, ``ROOT`` and ``EROOT`` always end with a trailing slash.
The rationale behind that was that the two latter variables frequently
pointed at the filesystem root (``/``), and therefore ebuilds had to
take care not to append a second slash to it.  To allow handling this
consistently for different values of ``ROOT``, the specification made
all variables always end with a slash.

While this reasoning makes sense, the behavior has been found unnatural
by many developers.  In the end, it created more double slashes than
it avoided.  Therefore, we decided to reverse that in EAPI 7 and now
all path variables are consistently guaranteed not to end with trailing
slash.  Hopefully, this will be less confusing in the end. This has two
implications.

Firstly, you always need to append the slash between path variables
and the actual path (but not the variable and prefix!):

.. code-block:: bash

    src_install() {
        # BAD: EAPI 6 form
        touch "${ED}usr/share/foo" || die
        # GOOD: EAPI 7 form
        touch "${ED}/usr/share/foo" || die
        # GOOD: portable cross-EAPI form
        touch "${ED%/}/usr/share/foo" || die

        # BAD: double slash here!
        touch "${D}/${EPREFIX}/usr/share/foo" || die
        # GOOD: variant with explicit EPREFIX (for some reason)
        touch "${D}${EPREFIX}/usr/share/foo" || die

        # GOOD: path returned by the tool starts with a slash
        touch "${D}$(mytool --get-some-path)/foo" || die
    }

Secondly, if a path references the root directory, it will be *empty*.
Yes, we know this is a little confusing.  However, it is rather rare
and it is consistent with how ``EPREFIX`` (or ``BROOT`` now) works.

.. code-block:: bash

    pkg_postinst() {
        # check whether we are installing to the host system

        # BAD: EAPI 6 form
        if [[ ${ROOT} == / ]]; then
            # ...
        fi

        # GOOD: EAPI 7 form
        if [[ -z ${ROOT} ]]; then
            # ...
        fi
    }


.. _einfo:
.. _elog:
.. _ebegin:
.. _eend:

Output commands no longer pollute stdout
----------------------------------------
The output channel for commands ``einfo``, ``elog``, etc. was undefined
in previous EAPIs.  As a result, the messages were frequently output
into stdout.  While this normally is not a problem, it limits
the ability of using them in eclass functions that might be called
via command substitution.  With the newly-added ``eqawarn`` this problem
becomes even more likely.

Starting with EAPI 7, those commands are guaranteed not to output
to stdout.  Therefore, their output will not be caught by command
substitution and you can use them safely e.g. to report deprecation
warnings:

.. code-block:: bash

    # my.eclass
    get_foo() {
        if ! has "${EAPI:-0}" 0 1 2 3 4 5 6; then
            eqawarn "get_foo() is deprecated in EAPI 7!"
        fi

        echo /usr/share/foo
    }

    # my-1.ebuild
    src_install() {
        insinto "$(get_foo)"
        doins test.foo
    }


.. _die:
.. _assert:

die and assert can be used in a subshell
----------------------------------------
EAPI 7 brings two important improvements to how the ``die`` machinery
works.  The first of them is lifting the restriction that said that
``die`` must not be used in a subshell.

This restriction was added historically due to the implementation
not being able to handle ``die`` from a subprocess correctly
(i.e. implicitly terminate the parent process).  However, over time such
an implementation became a necessity.  EAPI 4 already specified that
most of the ebuild helpers die on their own, at the same time specifying
that they must be implemented as external commands.  So the rationale
is simple: if the package manager must provide a logic for its external
commands to ``die`` reliably, there is no reason not to provide it
for subshells in bash code.

.. code-block:: bash

    # EAPI 6 version
    dofoo() {
        (
            insinto /usr/share/foo
            # unclear if strictly necessary
            nonfatal doins "${@}"
        ) || die -h "dofoo failed"
    }

    # EAPI 7 version
    dofoo() {
        (
            insinto /usr/share/foo
            doins "${@}"
        )
    }

    # EAPI 6 version
    get_foo() {
        if foo_works; then
            real_get_foo
        else
            # I can't die!
            return 1
        fi
    }

    src_configure() {
        local foo
        foo=$(get_foo) || die
    }

    # EAPI 7 version
    get_foo() {
        if foo_works; then
            real_get_foo
        else
            die "foo does not work!"
        fi
    }

    src_configure() {
        local foo=$(get_foo)
    }


.. _nonfatal:

nonfatal implemented both as function and external command
----------------------------------------------------------
The second change is specifying how ``nonfatal`` should be implemented.
In previous EAPIs, it was unspecified and the package managers
frequently implemented is a pure shell function.  Starting with EAPI 7,
it is implemented *both* as a function and an external command, making
it possible to use it safely in both contexts.

The implementation as a shell function makes it possible to call other
shell functions via ``nonfatal``, which is especially important since
``die`` started to support respecting it in EAPI 5.  The implementation
as an external command makes it possible to call it e.g. via ``find``
or ``xargs`` in more natural way.

.. code-block:: bash

    try_other_tests() {
        emake -j1 check-1
        emake check-2
    }

    src_test() {
        # Works in EAPI 4 and newer
        if ! nonfatal emake check; then
            eerror "Tests failed, please attach blah blah blah."
            die "Tests failed"
        fi

        # Requires EAPI 7: try_other_tests is a shell function
        if ! nonfatal try_other_tests; then
            eerror "Other tests failed, please attach blah blah blah."
            die "Other tests failed"
        fi
    }

    src_install() {
        insinto /usr/share/mytext

        # Works in EAPI 4 and newer
        if ! nonfatal find -name '*.txt' -exec doins {} +; then
            die "Installing text files failed for some reason!"
        fi

        # Requires EAPI 7: nonfatal called via subprocess
        if ! find -name '*.txt' -exec nonfatal doins {} +; then
            die "Installing text files failed for some reason!"
        fi
    }


.. _domo:

domo install path corrected
---------------------------
In earlier EAPIs, the ``domo`` function (used to install localizations)
respected the install prefix set by ``into``.  This was inconsistent
with similar functions such as ``dodoc``, ``doinfo`` and ``doman``
which installed data files to ``/usr/share`` independently of the prefix
set.  EAPI 7 modifies ``domo`` to stop respecting the prefix and also
use ``/usr/share`` unconditionally.


.. _`|| ( )`:
.. _`^^ ( )`:

Empty dependency groups no longer satisfy dependencies
------------------------------------------------------
Originally, PMS specified that empty dependency groups of any type count
as being matched (i.e. satisfy the dependency).  This behavior was found
contrary to the rules of boolean algebra, and likely to hide problems
such as generated parts of dependencies no longer listing any packages.
To address this, two changes were applied.

Firstly, the specification has been changed retroactively to require
at least one child element for every type of explicit dependency group.
Explicit empty groups (e.g. ``|| ( )``) never served any purpose,
and were not reliably accepted by the different package managers.
Therefore, they are banned now.

Secondly, the behavior of implicitly formed empty groups (that can occur
when they nest USE-conditional groups whose conditions do not match)
has been modified to match the rules of boolean algebra in EAPI 7.
An empty group has zero matching items, and should behave the same
as a non-empty group with zero matching items.  Therefore, an empty
any-of (``||``) or exactly-one-of (``^^``) group no longer satisfies
dependencies while an empty at-most-one-of (``??``) group does.

.. code-block:: bash

    # This will trigger an error if gen_deps outputs empty string
    DEPEND="|| ( $(gen_deps) )"

    # EAPI 6: this is satisfied w/ USE="-a -b"
    # EAPI 7: requires a+foo OR b+bar
    REQUIRED_USE="|| ( a? ( foo ) b? ( bar ) )"

    # EAPI 6: this is satisfied w/ USE="-a -b"
    # EAPI 7: requires a+foo XOR b+bar
    REQUIRED_USE="^^ ( a? ( foo ) b? ( bar ) )"


Profile changes
===============

.. _package.mask:
.. _package.use:
.. _package.use.force:
.. _package.use.mask:
.. _use.force:
.. _use.mask:

Directories in profiles supported (not for ::gentoo!)
-----------------------------------------------------
EAPI 7 allows a number of files in the ``profiles`` subtree to
be replaced by directories, in Portage style.  This includes
the top-level ``package.mask`` file and the following files in every
profile:

- ``package.mask``
- ``package.use``
- ``package.use.force``
- ``package.use.mask``
- ``package.use.stable.force``
- ``package.use.stable.mask``
- ``use.force``
- ``use.mask``
- ``use.stable.force``
- ``use.stable.mask``

If any of those files is replaced by a directory, the package manager
will concenate all non-dot files in that directory and use their
contents instead of the original file.

This has been approved with the specific note that it will be banned
from the Gentoo repository by policy, where profiles will continue
using regular files for the time being.  In other words, it's intended
as convenience for Gentoo forks (which amend Gentoo profiles) and other
third-party repositories.


.. _package.provided:

package.provided is gone for good
---------------------------------
.. Note::

   This applies to use of ``package.provided`` in the repository.
   It does not apply to the use in ``/etc/portage``.

Finally, PMS bans the ``package.provided`` file from profiles in EAPI 7.
This file could have been used to ‘pretend’ that some packages were
installed while actually not using the relevant ebuilds.  This was
a horrible hack that did not support slots or USE flags correctly,
and it was only used by a few uncommon profiles, for obsolete reasons.

Eventually, all uses were removed and the file is now banned.
The replacement for it is to use modern virtual packages.


Rejected and postponed features
===============================

Minimal bash version at 4.3
---------------------------
One of the suggestions for EAPI 7 was to require bash-4.3.  However,
this was rejected as it was determined that it does not add any ‘killer
features’ that could benefit ebuilds.


Sandbox path removal functions
------------------------------
The initial version of EAPI 7 draft included four functions to remove
paths added by ``add*`` Sandbox functions.  This feature has been
initially accepted and implemented in Portage.  However, it was
eventually removed and postponed into a future EAPI in order to improve
the interface — in particular, replace the 4 (or 8, with the changes)
commands to manipulate paths with a single ``esandbox`` helper.


Runtime-switchable USE flags
----------------------------
This request dates back to 2012.  It was codified into GLEP 62
[#GLEP62]_, and included in the EAPI 6 feature list.  It aimed
to provide a better solution for expressing optional pure runtime
dependencies.  That is, dependencies that do not need to be present
at build time but allow the package to expose additional features when
installed afterwards.

Using regular USE flags for those dependencies would force users to
needlessly rebuild the whole package in order to enable or disable such
a dependency.  For this reason, the common practice is to print those
dependencies as postinst message and expect users to install them
manually.  The idea was to add a special class of USE flags whose state
could be switched in-place without having to rebuild the package
in question.

Sadly, this feature was deferred once again due to lack
of implementation for Portage.


||= — binding any-of dependency groups
--------------------------------------
The initial proposals date back to 2013.  This also is a feature that
was postponed from EAPI 6.  The problem being solved is that the ``||``
any-of dependency groups work correctly only for pure build-time or pure
runtime dependencies.  If the package binds to one of the ‘providers’
in ``||`` (e.g. links to the library) and the user uninstalls it
in favor of another one, the package becomes broken.

This problem has resulted e.g. in introducing binary USE flags to switch
between providers that block each other, e.g. in case of OpenSSL vs
LibreSSL, FFmpeg vs libav.  The ``||=`` operator meant to solve
the problem by ‘binding’ the package to the current provider.  The idea
was inspired by the ``:=`` slot operator; switching between different
allowed providers would require rebuilds of the package.

This feature was also deferred due to lack of implementation
for Portage.


Automatic REQUIRED_USE enforcing
--------------------------------
This idea is pretty recent, and it has been described in GLEP 73
[#GLEP73]_.  It meant to solve some of the problems reported
for ``REQUIRED_USE`` constraints.  Most notably, that their widespread
use frequently requires manual resolution and clutters configuration
files with changes that may only be required temporarily.  This results
in some of the developers avoiding ``REQUIRED_USE``, and some having
to use ugly hacks (such as split of practically equivalent flags
into ``PYTHON_TARGETS`` and ``PYTHON_SINGLE_TARGET``).

The solution proposed was to clearly define the algorithmic meaning
of REQUIRED_USE and allow the package manager to automatically adjust
USE flags in order to resolve the conflicts.  For example,
if the package in question did not support using multiple Python
interpreters, the package manager would automatically choose one
of the enabled implementations.

This feature was rejected by the Council.  It also had no implementation
in Portage.


Cheat sheet / index
===================
The table following lists all the changes in a grep-for form that could
be used as a reference when upgrading ebuilds from EAPI 6 to EAPI 7.

  ==================== =================================================
  Search term          Change
  ==================== =================================================
  EAPI commands / functions
  ----------------------------------------------------------------------
  assert_              now legal in subshell
  best_version_        -b, -d, -r for different dependency types
  die_                 now legal in subshell
  dohtml_              removed; replacement: ``dodoc -r``, ``docinto``
  dolib_               removed; replacement: ``dolib.a``, ``dolib.so``
  domo_                no longer respects ``into``, always uses /usr
  dostrip_             new command; controls stripping per file
  eapply_              GNU patch 2.7 guaranteed, git patches supported
  eapply_user_         GNU patch 2.7 guaranteed, git patches supported
  ebegin_              no longer outputs to stdout
  econf_               passes --build, --target, --with-sysroot
  eend_                no longer outputs to stdout
  einfo_               no longer outputs to stdout
  elog_                no longer outputs to stdout
  eqawarn_             new command; prints QA warning for devs
  has_version_         -b, -d, -r for different dependency types
  libopts_             removed; replacement: ``doins`` w/ ``get_libdir``
  nonfatal_            implemented both as external helper and function
  ver_cut_             new command; cuts components from version string
  ver_rs_              new command; replaces separators in version str
  ver_test_            new command; compares two versions
  -------------------- -------------------------------------------------
  Eclass functions
  ----------------------------------------------------------------------
  doicon               provided by desktop.eclass_
  domenu               provided by desktop.eclass_
  ecvs_clean           provided by vcs-clean.eclass_
  egit_clean           provided by vcs-clean.eclass_
  epatch               banned; see epatch.eclass_
  eshopts_*            provided by estack.eclass_
  estack_*             provided by estack.eclass_
  esvn_clean           provided by vcs-clean.eclass_
  eumask_*             provided by estack.eclass_
  evar_*               provided by estack.eclass_
  make_desktop_entry   provided by desktop.eclass_
  make_session_desktop provided by desktop.eclass_
  newicon              provided by desktop.eclass_
  newmenu              provided by desktop.eclass_
  preserve_old_lib     provided by preserve-libs.eclass_
  prune_libtool_files  banned; see ltprune.eclass_
  -------------------- -------------------------------------------------
  Eclasses
  ----------------------------------------------------------------------
  eapi7-ver.eclass_    banned; all built-in in EAPI 7
  epatch.eclass_       banned; replacement: ``eapply`` (built-in)
  eutils.eclass_       most functions moved into different eclasses
  ltprune.eclass_      banned; replacement by inline snippet
  versionator.eclass_  banned; replacement: ver_cut_, ver_rs_, ver_test_
  -------------------- -------------------------------------------------
  Variables
  ----------------------------------------------------------------------
  BDEPEND_             new metadata var; for CBUILD build-dependencies
  BROOT_               new variable; location where BDEPEND is installed
  DEPEND_              split into DEPEND (CHOST) and BDEPEND (CBUILD)
  DESTTREE_            removed; replacement: ``into``
  D_                   no longer ends with a trailing slash
  ECLASSDIR_           removed; no replacement
  ED_                  no longer ends with a trailing slash
  ENV_UNSET_           new profile var; blacklists envvars from host
  EROOT_               no longer ends with a trailing slash
  ESYSROOT_            new variable; SYSROOT + EPREFIX
  INSDESTTREE_         removed; replacement: ``insinto``
  PORTDIR_             removed; no replacement
  ROOT_                no longer ends with a trailing slash
  SYSROOT_             new variable; location where DEPEND is installed
  -------------------- -------------------------------------------------
  Profile files
  ----------------------------------------------------------------------
  package.mask_        can be a directory now
  package.provided_    banned from profiles
  package.use.force_   can be a directory now (+ stable variant)
  package.use.mask_    can be a directory now (+ stable variant)
  package.use_         can be a directory now
  use.force_           can be a directory now (+ stable variant)
  use.mask_            can be a directory now (+ stable variant)
  -------------------- -------------------------------------------------
  Other
  ----------------------------------------------------------------------
  `^^ ( )`_            empty exactly-one-of group now evaluates as false
  `|| ( )`_            empty any-of group now evaluates as false
  ==================== =================================================


References
==========

.. [#EAPI6_GUIDE] The Ultimate Guide to EAPI 6 by Michał Górny
   (https://blogs.gentoo.org/mgorny/2015/11/13/the-ultimate-guide-to-eapi-6/)

.. [#GLEP62] GLEP 62: Optional runtime dependencies via runtime-
   switchable USE flags
   (https://www.gentoo.org/glep/glep-0062.html)

.. [#GLEP73] GLEP 73: Automated enforcing of REQUIRED_USE constraints
   (https://www.gentoo.org/glep/glep-0073.html)
