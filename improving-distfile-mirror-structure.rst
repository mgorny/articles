===================================
Improving distfile mirror structure
===================================
:Author: Michał Górny
:Date: 2019-10-13
:Version: 1.2
:Copyright: https://creativecommons.org/licenses/by/4.0/


.. contents::


Preface
=======
The Gentoo distfile mirror network is essential in distributing sources
to our users.  It offloads upstream download locations, improves
throughput and reliability, guarantees distfile persistency.

The current structure of distfile mirrors dates back to 2002.  It might
have worked well back when we mirrored around 2500 files but it proved
not to scale well.  Today, mirrors hold almost 70 000 files, and this
number has been causing problems for mirror admins.

The most recent discussion on restructuring mirrors started
in January 2015.  I have started the preliminary research
in January 2017, and it resulted in GLEP 75 being created
in January 2018.  With the actual implementation effort starting
in October 2019, I'd like to summarize all the data and update it
with fresh statistics.  [#MIRROR-BUGREPORT]_ [#GLEP75]_


Current state of distfile mirrors
=================================

Mirror setup
------------
The official Gentoo mirror list includes 63 mirrors at the moment.
Almost all of them are outside Gentoo control, and are administered
by various individuals.  They generally use rsync to fetch data
from Gentoo's master mirror but it is unclear what exact rsync options
are used.  The Infra documentation did not include an explicit
recommendation for those until 2015.  [#MIRRORS]_

The rsync options regarding hard link and symbolic link handling
are of specific interest to the mirror layout switch.

Hard links are not detected by rsync by default, and therefore hard
linked files are transferred and stored separately on the target
filesystem.  This can be changed using ``--hard-links`` option that
causes rsync to detect hard links on the source filesystem
and to recreate them.

In January 2018, Robin H. Johnson attempted to survey mirror admins
with regards to the use of this option.  The original thread receives
5 replies, 3 of them indicating that the discussed option was enabled
prior, the remaining 2 mirrors enabling it afterwards.  The number
of replies was too small to make a positive general assumption
but through extrapolation we can suspect that even 40% of mirrors
may not preserve hard links.  [#HARDLINK-SURVEY]_

Symbolic links are not transferred by rsync by default.  There are a few
options that enable handling them, notably ``--links`` that enables
copying symbolic links, and ``--copy-links`` that resolves them
and copies underlying files.  The former option is implicitly enabled
by ``--archive``.

The specific behavior of rsync makes it possible to remotely test
for symlink support.  For this purpose, I have planted a symlink
on the master mirror on 2019-10-07.  Two days later, the majority
of mirrors successfully mirrored the symlink.  2 mirrors have not synced
yet, and one gives 403 error (though it gives 404 for non-existing
files, so it probably copied the symlink correctly and rejects access
to the underlying file).


Distfile structure
------------------
The distfiles are placed in a single directory, using local filenames
specified by ebuilds (either inferred from the URI, or specified using
the arrow operator).  Distfiles for newly added packages are added
immediately, while old distfiles are removed after an additional delay.

As of 2019-10-09 10:00 UTC, the master mirror includes 69 617 files,
totalling approximately 260 GiB.  The Manifests in matching Gentoo
repository tree contain approximately 54 651 unique distfiles.  This
indicates that over 20% of files stored on the mirrors are preserved
old distfiles.  [#DIST-NOTE]_

A plain text index of all files (created through calling ``find``)
is almost 2 MiB of size.  Generating a HTML index by the web server
takes a few seconds, and produces 15 MiB of data.  Plain
``ls >/dev/null`` with warm cache takes almost half a second.

The biggest distfile group belongs to TeΧ Live, that counts 16 075
files.  This accounts for 23% of all mirrored distfiles.  The second
most common prefix is ``github.com`` which belongs to Go packages,
and includes 1120 files.  All other apparent groups have less than
1% share.

.. figure:: improving-distfile-mirror-structure/distfile-count-over-time.svg

   Figure 1a: number of distfiles in the Gentoo repository

.. figure:: improving-distfile-mirror-structure/distfile-size-changes.svg

   Figure 1b: monthly distfile removals and additions

The plot in figure 1a presents the number of uniquely-named distfiles
in the Gentoo repository and their respective total size, as indicated
by either the historical digest files or the newer Manifest2 format.
The totals were omitted from the plot since they were indistinguishable
from the higher of the two values.  The plot in figure 1b presents
total size of removed and added distfiles compared to the previous
month.  [#PLOT-NOTE]_

The plot shows a rather steady incline of total distfile counts, with
noticeable peaks corresponding to major version bumps (especially TeΧ
Live), and troughs matching the removal of old versions.

There are also noticeable peaks on the size plot that correspond
to adding very large files, especially lately.  It is interesting that
the rapid decline of distfile count around 2017 did not correspond
with major reduction of total size — indicating that a large amount
of small files were removed.

.. [#DIST-NOTE] The count of distfiles indicated by Manifests is rough,
   since I did not precisely filter all fetch- or mirror-restricted
   packages.

.. [#PLOT-NOTE] The data used for plot was not filtered for fetch-
   or mirror-restricted packages.  Therefore, it is unsurprising that
   it vastly exceeds the actual space used on the mirrors.  Sadly,
   filtering historical data is non-trivial and would be very
   time-consuming.


Proposed replacement layouts
============================

Filename prefix-based layout
----------------------------
The most straightforward method of grouping distfiles is to group
by a common filename prefix, in particular by the first character
of filename.  Assuming case-insensitive matching, we can create
26 groups corresponding to letters, plus one group for the remaining
characters.  Such a split is presented on figure 2.

.. figure:: improving-distfile-mirror-structure/filename-prefix-layout.svg

   Figure 2: grouping of distfiles by first character of filename

Please note that the y axis of the plot is on logarithmic scale.
The proposed split is uneven.  The ``t`` group features 18 730 files,
larger groups feature up to 5000 files, the smallest around 250.
Besides being very uneven, this split does not resolve the problem
of huge directories.

Because of the number of files starting with ``texlive`` prefix, even
longer prefix would not resolve the problem.  Technically, using
a dynamic prefix length might help by isolating TeΧ Live packages
into a few dedicated groups.  However, this increases the complexity
of the solution, and still does not scale well.  For example, adding
a new version will double the size of all the TeΧ Live groups,
and removing an old version will reduce them to half the previous size.


Filename-delimited (paged) layout
---------------------------------
Another solution based on filenames was proposed by Andrew Barchuk.
It based on splitting sorted filenames into buckets of the same size,
and using the first filename in each group as a delimiter.  This has
the obvious advantage that the groups are initially even.  [#BARCHUK]_

For example, if we choose a bucket size of 1000 files, the initial split
would introduce 70 groups.  A few example groups would be:

- [``01-iosevka-1.14.1.zip``] .. [``amsynth-1.8.0.tar.bz2``]
- ``AM.tar.gz`` .. [``asterisk-core-sounds-es-gsm-1.4.22.tar.gz``]
- ``asterisk-core-sounds-es-siren14-1.4.21.tar.gz`` .. [``bash40-019``]
- ...
- ``tcl8.4.15-src.tar.gz`` ..
  [``texlive-module-anyfontsize-2019.tar.xz``]
- ``texlive-module-anyfontsize.doc-2017.tar.xz`` ..
  [``texlive-module-betababel.doc-2017.tar.xz``]
- ...
- ``xwem-1.26-pkg.tar.gz`` .. [``zzuf-0.15.tar.bz2``]

Please note that filenames given in braces are not delimiting,
i.e. additional distfiles may be added before/after them.

While this solution evens out group sizes pretty well at first, it does
not scale well.  For example, TeΧ Live bump will (again) double the size
the relevant groups instead of being distributed evenly.  It is complex,
and the necessity of reshuffling may require relatively frequent
maintenance.

The infeasibility of this solution can be best proven by considering
what would happen if the groups were created prior to the introduction
of the first TeΧ Live version.  In this case, all 8000+ ebuilds would
land in a single group.


Category/package-based layout
-----------------------------
Jason Zaman has proposed to reuse the layout from ebuild repository,
i.e. split by category or package and category pair.  This solution has
not been given much thought for three reasons.  [#ZAMAN]_

Firstly, it prevents trivial reuse of the same distfiles that are shared
between multiple packages.  While technically this could be possible
by using hard links or symbolic links, it's going to be non-trivial
and fragile.

Secondly, it does not solve the problem of directories having a large
number of files.  For example, ``dev-texlive/texlive-latexextra``
features over 6000 files itself.  The largest Manifests at the time
of writing are (in lines)::

    6161 dev-texlive/texlive-latexextra/Manifest
    1213 dev-texlive/texlive-fontsextra/Manifest
    1020 games-board/tablebase-syzygy/Manifest
     967 dev-texlive/texlive-publishers/Manifest
     858 net-p2p/bisq/Manifest
     858 dev-texlive/texlive-mathscience/Manifest
     801 dev-texlive/texlive-pictures/Manifest
     568 dev-texlive/texlive-bibtexextra/Manifest
     504 app-office/libreoffice-l10n/Manifest
     490 dev-texlive/texlive-pstricks/Manifest
     378 dev-texlive/texlive-plaingeneric/Manifest
     372 www-client/firefox/Manifest
     358 www-client/firefox-bin/Manifest
     321 app-shells/bash/Manifest
     319 app-text/texlive-core/Manifest
     316 dev-texlive/texlive-latexrecommended/Manifest
     291 dev-util/sccache/Manifest
     276 x11-terms/alacritty/Manifest
     273 dev-texlive/texlive-langeuropean/Manifest
     268 dev-util/cargo-tree/Manifest

Thirdly, the groups would be very uneven still, and the resulting split
would be inefficient.  If grouping were done by package, there will be
a huge number of directories having no more than a few distfiles.


File hash-based layout
----------------------
Another option considered was to reuse the hash of distfile in question.
eryptographic hash functions are generally expected to produce
divergent results even for apparently insignificant differences
in input.  This gives a good chance for the distribution to remain even
through future distfile changes.

For the purpose of testing, Blake2b hashes truncated to the respectively
4 and 8 most significant bits were considered.

.. figure:: improving-distfile-mirror-structure/file-hash-1x.svg

   Figure 3a: grouping of distfiles by 4 msb of content hash

.. figure:: improving-distfile-mirror-structure/file-hash-2x.svg

   Figure 3b: grouping of distfiles by 8 msb of content hash

The 4-bit hash variant produces 16 groups, having between 4250 and 5000
distfiles each.  The 8-bit variant produces 256 groups, having between
230 and 320 files each.  The latter proves satisfactorily even, with
no groups exceeding 500 files in the foreseeable future.  Technically,
we could try using an interim value such as 6 bits; however, multiples
of four are more convenient since they can be trivially cut
from the commonly used hexadecimal encoding.

This method generally relies on the hash values being present
in Manifests.  Its main disadvantage is that the client can not predict
the path otherwise.  While this could technically be resolved by using
a supplementary index, refreshing this index involves additional
bandwidth usage that may even exceed the size of smaller distfiles.


Filename hash-based layout
--------------------------
The final proposed variant, and the one chosen to implement the new
layout was to use the hash of the filename.  Its advantage is that it
can be calculated entirely without additional information,
and the cryptographic hash functions should retain their properties even
with low entropy input that filenames are.

For the purpose of testing, Blake2b hashes truncated to the respectively
4 and 8 most significant bits were considered.  [#HASH-NOTE]_

.. figure:: improving-distfile-mirror-structure/filename-hash-1x.svg

   Figure 4a: grouping of distfiles by 4 msb of filename hash

.. figure:: improving-distfile-mirror-structure/filename-hash-2x.svg

   Figure 4b: grouping of distfiles by 8 msb of filename hash

Curious enough, this variant produces even more even groups.  The 4-bit
version gives between 4250 and 4500 distfiles in each group, while
the 8-bit variant produces between 230 and 320 files.

.. [#HASH-NOTE] During the discussion, it was argued that a simpler
   hash function should be used.  However, the choice of hash function
   was not done based on its cryptographic strength (or speed)
   but merely because the same function is used in Manifest files.
   Reusing the same algorithm reduces the number of different functions
   the package manager needs to implement.  Furthermore, the input
   is small enough for the performance differences to be insignificant.


Reliability of filename hash over time
--------------------------------------
Of all the options proposed so far, the filename hash is the most
promising: it is flexible, easy to compute and does not require
additional information.  Let's see how it copes with historical
distfiles.

.. figure:: improving-distfile-mirror-structure/filename-hash-over-time.svg

   Figure 5: Statistical analysis of filename hash split applied
   to historical data

Figure 5 combines two sets of statistical data.  The first plot compares
mean group size with the median.  Additionally, minimum and maximum
group sizes are indicated via error bars.  The second plot expresses
relative standard deviation.

Initially, the standard deviation is relatively high due to small group
sizes.  After all, the choice of 256 groups was based on the current
distfile count, and none of the groups reaches the count of 50 files
before 2004.  Afterwards, it settles below 10%, and generally decreases
as distfile number grows.

The min/max values indicate that even with the highest number
of distfiles recorded, the largest group is well below the threshold.
Therefore, it seems reasonable to assume that this layout will work well
for many years to come.  It is probably more likely that a future layout
change would occur as a consequence of Manifest hash change than
the necessity of reshuffling distfiles.


Migration path
==============

General migration plan
----------------------
GLEP 75 has introduced a ``layout.conf`` file that is placed in the top
``distfiles`` directory of a mirror and specifies the layout used.
The clients are expected to fetch this file before using the mirror
in question, and use the layout that they support.  If the file
is not present, the client falls back to assuming the legacy flat
layout.

This solution allows for graceful layout switches, both this time
and in the foreseeable future.  Mirrors that are synced from the Gentoo
master mirror will obtain both the new layout and the configuration file
via rsync.  Custom mirrors will continue to work as-is using the flat
layout.

Nevertheless, the process of switching mirror layout needs to account
for two problems.

Firstly, if the new layout was not implemented by the package
managers before, we need to continue supporting the old layout for
a lengthy transition process until we can assume that the users have
updated their systems.

Secondly, we need to assume that mirrors will not update their layouts
atomically.  Instead, we need to provide some time for mirrors to fetch
the new layout before indicating its presence to the users.  We also
need to account for user-side caching.

Therefore, the following migration plan is devised:

1. ``emirrordist`` is switched to use both the old and new layout
   simultaneously for newly-mirrored distfiles.

2. The existing distfiles are mirrored into the new layout.

3. When the mirrors can be assumed to have synced all the changes,
   ``layout.conf`` is updated so that users switch to the new layout.

4. A transitional period ensues.

5. Once the transitional period is over, the old layout is removed
   from ``layout.conf``.

6. The old layout is removed from the mirrors.

The remaining problem is how to solve the transitions in order to avoid
both transferring all the existing distfiles again and storing two
copies of the same file during the transitional period.


Hard link solution
------------------
One particularly interesting solution is to use hard links between both
layouts.  If rsync has ``--hard-links`` option enabled, it will both
avoid transferring the files twice and avoid occupying double the space.
In my testing, rsync was able to process a complete layout switch
for all distfiles within a few seconds, transferring approximately 7 MiB
of data.

The disadvantage of this solution is that it does not work when mirrors
do not use the discussed option.  In that case, all files will be
transferred over again and the disk usage will double during
the transitional period.  Therefore, if this option is chosen, some
mirrors will suffer additional bandwidth usage during the initial
transition, and additional disk usage during the lengthy transitional
period.


Symbolic link solution
----------------------
The more reliable alternative is to use symbolic links.  So far we
aren't aware of any mirrors not supporting them, and they certainly
avoid doubling the space needed to store distfiles.  Experimentally,
I've confirmed that transferring the layout change as symlinks has
approximately the same performance and bandwidth characteristics as hard
links.

However, the cleanup of old layout requires replacing the symlinks
with regular files.  To my knowledge, rsync does not support such
a scenario, therefore this transition will involve transferring all
the distfiles again.  This solution will save all mirrors from
the increased disk space usage but all will suffer additional bandwidth
usage during the final transition (cleanup).


Hybrid solution
---------------
Finally, both options can be combined to provide the best of two worlds.
During the transitional period, symlinks are used to link both layouts
without consuming the disk space twice.  They are temporarily replaced
by hard links while switching the primary layout in order to avoid
transferring the file contents again.

The mirrors using ``--hard-links`` option will fully benefit
from the advantages of hard links.  The remaining mirrors will still
transfer the files again and store them twice.  However, the actual
impact will be limited by performing the transition in smaller groups.
While some mirrors will suffer additional bandwidth and disk space use,
the issue will be limited to short periods of time and smaller groups
of distfiles.


Summary
=======
The historical layout of distfile mirrors does not scale well to modern
distfile counts.  While the majority of servers can cope with this,
switching to a layout splitting files between multiple directories
has the potential of improving performance and reliability.

Among offered solutions, using a portion of hash of filename seems to
be the best one.  Its main advantages are that it is relatively simple
to implement, offers good distribution of distfiles and seems reasonably
future proof.  The preferred hash function is Blake2b, to match
the primary algorithm used for Manifests, with 8-bit prefix providing
reasonably small and future-proof group sizes.

The layout switching is done via per-mirror ``layout.conf`` files.  This
makes it possible for every mirror to use a different layout.  Most
notably, mirrors syncing from the master mirror will implicitly switch
to the new layout, while custom mirrors will continue working correctly
with the flat layout.  This will also make future layout switches
easier.

The change of layout involves a potentially lengthy transition period,
during which both old and new layouts will need to be provided
simultaneously.  A hybrid approach utilizing symbolic links during most
of the transition period and hard links for the primary layout switch
should reduce the impact on mirrors to the possible minimum.
The mirrors without ``--hard-links`` option enabled will suffer
additional bandwidth use and temporary duplication of some distfiles.

That said, everything is practically ready for the change.  There are
a few patches still waiting for review, and a new Portage release to
be made.  The helper scripts for master mirror migration are ready,
and the complete process has been tested.  Once the last details
are confirmed and the new software is deployed, the transition
can start.


References
==========

.. [#MIRROR-BUGREPORT] Bug 534528 - distfiles should be sorted into
   subdirectories of DISTDIR
   (https://bugs.gentoo.org/534528)

.. [#GLEP75] GLEP 75: Split distfile mirror directory structure
   (https://www.gentoo.org/glep/glep-0075.html)

.. [#MIRRORS] Gentoo source mirrors
   (https://gentoo.org/downloads/mirrors/)

.. [#HARDLINK-SURVEY] Robin H. Johnson, [gentoo-mirrors] Mirror survey
   re rsync --hard-link (distfiles/releases/experimental/snapshots)
   (https://archives.gentoo.org/gentoo-mirrors/message/3d858e29845e7626d9b376c65b64f8b7)

.. [#BARCHUK] Andrew Barchuk, Re: [gentoo-dev] [pre-GLEP] Split distfile
   mirror directory structure
   (https://archives.gentoo.org/gentoo-dev/message/611bdaa76be049c1d650e8995748e7b8)

.. [#ZAMAN] Jason Zaman, Re: [gentoo-dev] [pre-GLEP] Split distfile
   mirror directory structure
   (https://archives.gentoo.org/gentoo-dev/message/f26ed870c3a6d4ecf69a821723642975)
