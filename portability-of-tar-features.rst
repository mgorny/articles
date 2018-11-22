===========================
Portability of tar features
===========================
:Author: Michał Górny
:Date: 2018-11-25
:Version: 1.0
:Copyright: https://creativecommons.org/licenses/by/3.0/


.. contents::


Preface
=======
The tar format is one of the oldest archive formats in use.  It comes
as no surprise that it is ugly — built as layers of hacks on the older
format versions to overcome their limitations.  However, given
the POSIX standarization in late 80s and the popularity of GNU tar, you
would expect the interoperability problems to be mostly resolved
nowadays.

This article is directly inspired by my proof-of-concept work on new
binary package format for Gentoo.  My original proposal used volume
label to provide user- and file(1)-friendly way of distinguish our
binary packages.  While it is a GNU tar extension, it falls within POSIX
ustar implementation-defined file format and you would expect that
non-compliant implementations would extract it as regular files.  What I
did not anticipate is that some implementation reject the whole archive
instead.

This naturally raised more questions on how portable various tar formats
actually are.  To verify that, I have decided to analyze the standards
for possible incompatibility dangers and build a suite of test inputs
that could be used to check how various implementations cope with that.
This article describes those points and provides test results
for a number of implementations.

Please note that this article is focused merely on read-wise format
compatibility.  In other words, it establishes how tar files should
be written in order to achieve best probability that it will be read
correctly afterwards.  It does not investigate what formats the listed
tools can write and whether they can correctly create archives using
specific features.


Implementations tested
======================
For the purpose of the experiment, the following implementations were
tested:

- **GNU tar** 1.30  [#GNUTAR]_
- **libarchive** 3.3.3  [#LIBARCHIVE]_
- **star** 1.5.3 (Schily)  [#STAR]_
- **NetBSD pax** from NetBSD 8.0 CVS, fetched 2018-11-22 (with local
  modifications to build on Linux)  [#NETBSD-PAX]_
- **busybox** tar 1.30.0  [#BUSYBOX]_
- **Python** tarfile module as provided by Python 3.7.0
  [#PYTHON-TARFILE]_
- **p7zip** 16.02  [#P7ZIP]_
- **7-Zip** 18.05 (using wine)  [#7ZIP]_
- **WinRAR** 5.61 (proprietary, using wine)  [#WINRAR]_


Test inputs
===========
All the test inputs are uploaded to tar-test-inputs repository
[#TAR-TEST-INPUTS]_.  They are mostly tarballs produced by either GNU
tar or libarchive bsdtar, with a few manually hacked to achieve desired
results.

The large file test tarballs are double-compressed using gzip.
The inner compression is ``gzip -1``, used to reduce the file sizes
from 8 GiB to 36 MiB while maintaining reasonable performance (warning!
it's a zipbomb!).  The outer compression is ``gzip -9``, used to reduce
the file size further for the git checkout.


Common tar formats
==================
A good reference on different tar formats is the ``tar(5)`` manpage
from libarchive [#TAR.5]_.  Of particular interest are four standards
supported by GNU tar:

- Old **v7** tar format (``--format=v7``),
- POSIX 1003.1-1988 (**ustar**) format (``--format=ustar``),
- POSIX 1003.1-2001 (**pax**) format (``--format=pax``),
- **GNU tar** 1.13.x format (``--format=gnu``).

Additionally, whenever applicable the two additional formats supported
by star were tested:

- **star** format (the old variant),
- **sun** tar format.

The old v7 tar format is the format used by the tar command supplied
with Unix v7, and apparently a common base for the remaining formats.
Its defining features are lack of magic bytes and severe limitations
(only regular files, hardlinks and symlinks; pathname up to 99 octets;
file size up to 8 GiB; user and group stored numerically).

The ustar format extends the v7 format by adding more header fields
into unused padding space.  It provides magic bytes along with version
field, user and group names up to 31 octets, support for more file types
and extension of pathname length with 154-octet prefix.  Some
of the implementations used draft version of ustar format that used
a different magic bytes and version.

The pax format extends the ustar format by allowing arbitrary attributes
to be stored as special archive members before the actual file entry.
This provides for unlimited length pathnames, file sizes; unlimited
precision timestamps, etc.  The defining feature of pax format is that
it allows for extensions, assuming that incompatible implementations
may write the extended attributes as regular files for user inspection.

The GNU tar format is derived from the v7 format separately from POSIX
formats.  It uses the same magic and version as the pre-POSIX ustar
format, and is partially compatible with it.  However, whereas ustar
provides for extending pathname length, GNU tar includes fields for
additional timestamps and some other metadata.  It also uses a few
additional member types to provide long pathnames and support for
multi-volume archives.

The star format is the format historically used by star implementation,
derived from v7 tar incompatibly with both ustar or GNU tar.  This
format does not carry ustar magic; incompatible implementations normally
recognize it as v7 tar then.  This format was later superseded by ustar-
compatible xstar and xustar formats.

The sun tar format is the format historically used by tar on SunOS.
It seems roughly equivalent to pax, except that uppercase ``X`` file
flag is used in place of lowercase ``x``, and that additional member
type is provided for ACLs.


Portability test results
========================

Tar format acceptance
---------------------
The goal of the first test is to verify whether the tar implementations
accept a trivial archive of given type.  The archive contains a single
regular file and does not use any extensions other than additional
timestamps that are stored by default.

For the purpose of the experiment, the following tar files were used:

- **v7** format archive (with no magic),
- POSIX **ustar** archive,
- **pre**-POSIX **ustar** archive (with old magic and version values),
- **pax** archive (with extended metadata),
- **GNU** tar archive,
- **GNU** tar **-G** archive (where the ``-G`` option causes additional
  timestamps to be written),
- **star** format archive (the old format, not compatible with ustar),
- **sun** tar format archive (with extended metadata, alike pax).

It should be noted that the pre-POSIX ustar format and GNU tar format
use the same values of magic bytes and version; however, they differ
in the use of some header fields.  Apparently, modern versions of GNU
tar default not to use atime/ctime fields which could be confused
with ustar's path prefix field.  An additional archive with those
fields explicitly forced was included to extend testing.

  =================== ==== ===== ========= ===== ===== ====== ==== ===
  Implementation       v7  ustar pre-ustar  pax   GNU  GNU -G star sun
  =================== ==== ===== ========= ===== ===== ====== ==== ===
  GNU tar              ✓     ✓       ✓       ✓     ✓     ✓     ✓    ✓ 
  libarchive           ✓     ✓       ✓       ✓     ✓     ✓     ✓    ✓ 
  star                 ✓     ✓       ✓       ✓     ✓     ✓     ✓    ✓ 
  NetBSD pax           ✓     ✓       ✓       P     ✓     T     ✓    P 
  busybox              ✓     ✓       ✓       ✓     ✓     T     ✗    ✗ 
  Python               ✓     ✓       ✓       ✓     ✓     T     ✓    ✓ 
  p7zip                ✓     ✓       ✓       P     ✓     T     ✓    P 
  7-Zip                ✓     ✓       ✓       W     ✓     T     ✓    P 
  WinRAR               ✓     ✓       ✓       ✓     ✓     ✓     ✓    P 
  =================== ==== ===== ========= ===== ===== ====== ==== ===

  ✓: archive extracted correctly

  ✗: file rejected as invalid

  P: file extracted correctly, pax headers extracted as files

  T: timestamp incorrectly interpreted as path prefix

  W: file extracted correctly, prints opaque header error warning

The conclusion is that all the tested implementations handle all common
tar formats well.  The more complete GNU format with additional
timestamps confuses many tools; however, they are not used by default
by GNU tar.  The star format is accepted by most interpretations (taken
as v7 tar); only busybox explicitly rejects it.

The pax format causes extended headers to be extracted
as files by a few implementations.


Long pathnames
--------------
The v7 tar format stores pathnames in a fixed field 100 octets long.
Since the string is null-terminated, this sets maximum filepath length
at 99 octets.  Newer tar formats support long pathnames in different
ways.

The ustar format introduces additional 155-octet prefix field
in the header.  If the path is longer than 99 octets, it can be split
at a path component boundary, and the 'prefix path' can be moved into
this field.  This gives a maximum path of up to 254 octets but the exact
limitations depend on the actual possibility of splitting on path
component.  Implementations not supporting the ustar format would
extract such file with partial (‘suffix’) path.

The pax format uses ``path`` extended attribute to store long paths.
Therefore, the maximum path length is limited only by extended attribute
member length.  Non-compliant implementations will extract the file
using short name stored in the file member (the value is
implementation-defined) and possibly extract the extended attributes for
user's inspection.

The GNU format uses additional ``L`` member preceding the file to store
the long path.  The maximum path length is limited only by maximum
member size.  Non-compliant implementations will extract the file using
short name stored in the regular file member and may extract the long
name as additional file.

The star format uses a prefix field similarly to ustar, and at the same
offset.  However, incompatibility may arise from the format lacking
ustar magic.  The xstar and newer formats are ustar-compatible.

  =================== ===== ===== ===== =====
  Implementation      ustar  pax   GNU  star 
  =================== ===== ===== ===== =====
  GNU tar               ✓     ✓     ✓     ✗  
  libarchive            ✓     ✓     ✓     ✗  
  star                  ✓     ✓     ✓     ✓  
  NetBSD pax            ✓     ✗     ✓     ✗  
  busybox               ✓     ✓     ✓     ✗  
  Python                ✓     ✓     ✓     ✓  
  p7zip                 ✓     ✗     ✓     ✗  
  7-Zip                 ✓     ✗     ✓     ✗  
  WinRAR                ✓     ✓     ✓     ✗  
  =================== ===== ===== ===== =====
  
  ✓: file extracted correctly

  ✗: file extracted using partial path

All tested implementations support ustar and GNU formats for long paths.
With the higher length limit, this makes the GNU format a clear winner.
The pax format metadata is extracted to text files by the other
implementations, making some degree of manual recovery possible.
The star format long paths are supported only by the original
implementation and Python tarfile module.


Large file sizes
----------------
The v7 format stores file size as octal number in a 12-octet field.
The strict format uses 11 octets, with the 12th being a terminator.
This results in a maximum file size of 8 GiB.

More lenient implementations allow for skipping the terminator, using
12 octal digits.  This increases the limit to 64 GiB.

Furthermore, some implementations (including GNU tar) allow for storing
the file sizes in binary (base-256) rather than octal form.  This is
signalled by setting the MSB of the first octet, and provides for 95-bit
integer size, i.e. 32768 YiB (it's so big that we lack a better prefix
for it).

Finally, the pax standard unsurprisingly provides a ``size`` extended
attribute that can be used to specify file sizes as decimal number
of any length.  It might be useful if you ever need to store more than
32768 YiB.
  
  =================== ======== ======== =====
  Implementation      12-digit base-256  pax 
  =================== ======== ======== =====
  GNU tar                ✓        ✓       ✓  
  libarchive             ✓        ✓       ✓  
  star                   ✗        ✓       ✓  
  NetBSD pax             ✓        ✗       ✗  
  busybox                ✓        ✓       ✗  
  Python                 ✓        ✓       ✓  
  p7zip                  ✓        ✓       ✗  
  7-Zip                  ✓        ✓       ✗  
  WinRAR                 ✓        ✓       ✓  
  =================== ======== ======== =====
  
  ✓: file extracted correctly

  ✗: file truncated, rest of archive misinterpreted

Out of three ways to indicate large file sizes, 12-digit storage
and base-256 encoding are supported by all but one tools.  However,
the 12-digit variant is not supported for writing GNU tar, libarchive
(where it is technically supported but hard-disabled in code) or star
which all switch to base-256 automatically.  Therefore, base-256 format
is more portable (and has much higher limit), though archives created
by it will not work on NetBSD at the moment.

Given that the correct read of the remainder of the archive depends
on correctly determining the data block size, unsupported large size
effectively makes the archive unusable.  The pax format may result
in the correct size being written to a text file but the user has
no trivial recovery means.


User and group information
--------------------------
In the v7 format, file ownership information is stored as numeric user
and group identifiers.  They are stored as 8-octet fields, therefore
being limited to 7 octal digits (which are equivalent to 21-bit
integer).  While the maximum number is not likely to be a problem,
using numeric identifiers rather than names does introduce problems
when different systems use different user/group mappings.

Similarly to file size field, some implementations permit using all
8 octets for octal numbers, or base-256 encoding (however, this is less
common than for file sizes).  Those practices can be used to extend
numeric identifiers to 24-bit and 63-bit integers respectively.

The ustar and GNU tar formats add username and group name fields that
are 32-octet long (31 characters + null terminator).

The star format also uses username and group name fields, except they're
located at different offsets and are 16-octet long.  The format is only
understood by star itself, and therefore was not included in the table.

Finally, the pax format provides extended attribute keys for both
user and group numeric identifiers (stored in decimal) and names.  This
extension effectively removes the forementioned limitations.

  =================== ======= ======== ===== ======== =====
  Tested feature      Large numeric UID/GID   Long names
  ------------------- ---------------------- --------------
  Implementation      8-digit base-256  pax  32-octet  pax
  =================== ======= ======== ===== ======== =====
  GNU tar                ✓        ✓      ✓      C       ✓  
  libarchive             ✓        ✓      ✓      ✓       ✓  
  star                   ✗        ✗      ✓      ✓       ✓  
  NetBSD pax             ✓        ✗      ✗      ✗       ✗  
  busybox                ✓        ✓      ✗      ✓       ✗  
  Python                 ✓        ✓      ✓      ✓       ✓  
  p7zip                  ✓        ✗      ✗      ✓       ✗  
  =================== ======= ======== ===== ======== =====
  
  ✓: user/group interpreted correctly

  ✗: user/group information ignored

  C: user/group name concatenated with the field following it

The support for large numeric user and group identifiers is mostly
consistent with support for large sizes, with the notable exception
of star and p7zip not supporting base-256 encoding on these fields.
The 8-octet variant is not used by common tools, making base-256 and pax
two commonly possible choices.  Choosing the former loses star support,
the latter busybox tar support.

32-octet long user and group names are supported by most
of the implementations.  The notable exception is GNU tar that
as of v1.30 relies on the null terminator being present and concatenates
the values with the fields following them when it's not.  GNU tar also
truncates the name at 31 octets when writing the archive.

Windows implementations were skipped from the test since they do not
seem to provide access to user/group information (7-Zip technical list
mode provides user/group names but it's no different from p7zip).


Timestamps
----------
Out of timestamps, the v7 format provides only for storing mtime.  It is
stored in 12-octet field, permitting 11 octal digits which
are sufficient for 33-bit timestamps.

The documentation suggests that historically negative octal numbers
might have been used for timestamps.  However, none of the tested
implementations seem to support that.

Again, some implementations permit using 12 octal digits and/or base-256
encoding.  The former provides for 36 bits of data, the latter
for 95-bit signed integer.

The GNU tar format provides additional fields for atime and ctime.
However, it seems that modern versions of GNU tar do not use them
by default.  They need to be enabled explicitly via ``-G`` option,
and they confuse some archivers (see `tar format acceptance`_).

The star format provides octal atime and ctime fields as well,
at different offsets than GNU tar.  They are only supported
by the original implementation.

Finally, the pax format provides ``atime``, ``ctime`` and ``mtime``
extended attributes that are stored as decimal floating-point numbers.
Therefore, they provide both unlimited range and precision.

  =================== ======== ===== ===== ======== ===== ====== =====
  Tested feature      Large positive mtime Negative mtime atime, ctime
  ------------------- -------------------- -------------- ------------
  Implementation      12-digit b-256  pax  base-256  pax  GNU -G  pax 
  =================== ======== ===== ===== ======== ===== ====== =====
  GNU tar                ✓       ✓     ✓      ✓       ✓     ✗      ✓  
  libarchive             ✓       ✓     ✓      ✓       ✓     ✓      ✓  
  star                   ✗       ✗     ✓      ✗       ✓     ✓      ✓  
  NetBSD pax             ✗       ✗     ✗      ✗       ✗     ✗      ✗  
  busybox                ✓       ✓     ✗      ✓       ✗     ✗      ✗  
  Python                 ✓       ✓     ✓      ✓       ✓     ✗      ✗  
  p7zip                  ✓       ✓     ✗      ✗       ✗     ✗      ✗  
  7-Zip                  ✓       ✓     ✗      ✓       ✗     ✗      ✗  
  WinRAR                 ✗       ✗     ✗      ✗       ✗     ✗      ✗  
  =================== ======== ===== ===== ======== ===== ====== =====
  
  ✓: timestamp interpreted correctly

  ✗: timestamp misinterpreted or ignored

The support for large positive mtimes formatted as 12-digit octal
vs base-256 seems to be equal.  However, similarly to the previous cases
the 12-digit format is not written out of the box and requires manual
code hacking, making base-256 the winner.

The support for negative mtimes provided by base-256 and pax format
is largely equal to the support for the formats themselves.  One notable
exception is p7zip that does not seem to interpret negative mtimes
as of 16.02.  It is possible that updating it to match 7-Zip current
would solve that.

As a curiosity, star seems to use large octal mtime values to indicate
negative mtimes, making it incompatible with the other implementations.

The support for atime and ctime seems to be very limited.  The tests
were based on restoring atimes, given that ctime can not be forced.
Of the tested implementations, only GNU tar, libarchive bsdtar and star
restored atimes.  Surprisingly, GNU tar could not be forced to restore
atime from GNU format archive.  It also required explicit ``-G`` option
to restore it from the pax format.

Python tarfile, p7zip and Windows archivers do not provide any way
to obtain atime or ctime (other than reading raw pax attributes).


Extended file metadata
----------------------
ACLs
~~~~
The pax format permits storing file ACLs in the ``SCHILY.acl.*`` family
of attributes.  While the entries have apparent star origins, they seem
to have become the de facto standard for ACLs.

According to tar(5), the Solaris and AIX tar formats provide explicit
entry type for ACL storage, and MacOS tar uses additional binary blob
for extended attributes.  Neither of those formats seem to be supported
by GNU tar, libarchive or star, so they are not tested here.


File flags
~~~~~~~~~~
Extended file flags (e.g. used by chflags(1) on BSD or lsattr(1)
and chattr(1) on Linux) can be stored in the ``SCHILY.fflags`` field.
However, support for this standard seems to be rather limited.
Furthermore, different implementations seem to be using different flag
names.


Generic extended attributes
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Generic extended attributes (xattr) are stored in pax archives in two
notations: ``SCHILY.xattr.*`` notation encoding attribute values inline
and ``LIBARCHIVE.xattr.*`` notation using base64 encoding of values.
GNU tar and star are using the former, while libarchive is using both
by default.


Attribute support test
~~~~~~~~~~~~~~~~~~~~~~

  =================== ====== ====== ====== ==========
  Feature             ACL    fflags generic xattr
  ------------------- ------ ------ -----------------
  Implementation      SCHILY SCHILY SCHILY LIBARCHIVE
  =================== ====== ====== ====== ==========
  GNU tar               ✓      ✗      ✓        ✗     
  libarchive            ✓      ✓#     ✓        ✓     
  star                  ✓      ✓#     ✓        ✗     
  NetBSD pax            ✗      ✗      ✗        ✗     
  busybox               ✗      ✗      ✗        ✗     
  Python                ✗      ✗      ✗        ✗     
  p7zip                 ✗      ✗      ✗        ✗     
  =================== ====== ====== ====== ==========
  
  ✓: extended attributes supported

  #: attribute only partially compatible

  ✗: extended attributes ignored

The support for extended file attributes is limited to GNU tar,
libarchive and star.  ACLs and generic xattrs are supported consistently
by all three of them.  File flags are supported only by libarchive
and star, and since the flag names they use only partially overlap,
archives are not fully compatible.

libarchive supports an additional base64-encoded variant of xattrs.
However, no other implementations seems to support it and libarchive
additionally stores more widely supported ``SCHILY.*`` variant for
compatibility.


Sparse files
------------
The support for archiving sparse files is entirely non-standarized.
In regular tar archives, the sparse areas are filled up with zeros.

The GNU tar format provides support for sparse fragments in custom
extension fields.  Up to 4 fragments can be stored within regular header
size; if more are necessary, additional blocks with fragment information
are appended after the header.

The newer GNU tar versions also three different (all GNU-custom) formats
for sparse files in the pax format.  They are called ``0.0``, ``0.1``
and ``1.0`` formats respectively.

For completeness, the tests also cover custom sparse file support
in the star and xstar formats.  The latter is partially compatible
with the extended header format used by GNU tar.

  =================== ===== ===== === === === ==== ===== ==========
  Variant group       GNU tar     pax (GNU.*) star       Extracted
  ------------------- ----------- ----------- ---------- ----------
  Implementation      small large 0.0 0.1 1.0 star xstar as sparse?
  =================== ===== ===== === === === ==== ===== ==========
  GNU tar               ✓     ✓    ✓   ✓   ✓   ✗     ✓       ✓      
  libarchive            ✓     ✓    ✓   ✓   ✓   ✗     ✗       ✓      
  star                  ✓     ✓    ✗   ✗   ✗   ✓     ✓       ✓      
  NetBSD pax            ✗     ✗    ✗   ✗   ✗   ✗     ✗      n/a     
  busybox               ✗     ✗    ✗   ✗   ✗   ✗     ✗      n/a     
  Python                ✓     ✓    ✓   ✓   ✓   ✗     ✗       ✓      
  p7zip                 ✓     ✓    ✗   ✗   ✗   ✗     ✗       ✗      
  7-Zip                 ✓     ✓    ✗   ✗   ✗   ✗     ✗      n/a     
  WinRAR                ✗     ✗    ✗   ✗   ✗   ✗     ✗      n/a     
  =================== ===== ===== === === === ==== ===== ==========
  
  ✓: file extracted correctly

  ✗: file extracted incorrectly or archive rejected

Sparse files are supported only by a few implementations.  The most
widely supported format is the old GNU format.  The GNU pax extensions
are supported only by GNU tar, libarchive and Python tarfile module.
p7zip supports archives with GNU format sparse files but extracts them
as regular (zero-padded) files.

The star format is supported only by the initial implementation.
The xstar formats maintains some binary compatibility with the old GNU
format, and works with GNU tar.  However, other implementations
supporting the GNU tar format do not seem that lenient.


Volume label
------------
The volume label is a GNU tar extension.  It is supported in GNU tar,
star and pax formats.

In GNU tar and star formats, the volume label is added as a special
``V`` type member.  Technically, this means that non-GNU implementations
should extract it as a regular file according to the POSIX ustar
specification on handling unknown vendor types.

In pax format, the volume label is written as ``GNU.volume.label``
global attribute.

  =================== ===== ===== ===== ==============================
  Implementation       GNU   pax  star  Notes
  =================== ===== ===== ===== ==============================
  GNU tar               ✓     ✓     ✓   included in ``-t``/``-v``
  libarchive            ✓     I     ✓  
  star                  W     I     I  
  NetBSD pax           W+F    P     F  
  busybox               ✗     I     ✗  
  Python                F     I     F  
  p7zip                 ✗     P     F  
  7-Zip                 ✗     P     F  
  WinRAR                F     I?    F   proprietary; can't verify pax
  =================== ===== ===== ===== ==============================
  
  ✓: file extracted correctly

  W: file extracted correctly, warning about file format

  I: file extracted correctly, attribute explicitly ignored

  F: label extracted as regular (empty) file with mode 0000

  P: file extracted correctly, pax headers extracted as files

  ✗: file rejected as malformed

The GNU volume label feature suffers serious portability problems.  Only
GNU tar and libarchive provide explicit support for it.  Its presence
in the GNU format causes multiple archivers to reject the archive
altogether.  The exact behavior of pax format is hard to determine since
the label is normally not extracted; the I/P flags determined
by examining the source code.


Multi-volume archives
---------------------
GNU tar and star support creating multi-volume archives.  However,
the multi-volume format is mostly intended for tape drives, and is
either inconvenient (requiring manually typing filenames) or completely
broken (vanilla star just hangs when switching files) for regular files.
With files, using split(1) is a better idea.

GNU tar can create multi-volume archives either with GNU tar or pax
file format.  The former is simpler, and uses special ``M`` member type
to indicate continuation of file from previous volume.  The latter uses
``GNU.volume.*`` pax attributes to store continuation info, storing
the continued member as regular file.  This makes it possible for
non-compliant implementations to extract file in parts for concatenation
by user.

star can create multi-volume archives in xstar, xustar and exustar
formats.  All those formats use ``M`` member type similarly to GNU tar,
plus additional ``V`` volume label in the first archive.  The xustar
format adds more continuation information to the second archive using
``SCHILY.*`` pax attributes.  The exustar format additionally adds
volume information to all volumes using ``SCHILY.*`` global pax
attributes.

  =================== ===== ===== ===== ====== =======
  Variant group       GNU tar     star                
  ------------------- ----------- --------------------
  Implementation       GNU   pax  xstar xustar exustar
  =================== ===== ===== ===== ====== =======
  GNU tar               ✓     ✓     1     1       1   
  libarchive            Z     Z     Z     Z       Z   
  star                  ✓     W     ✓     ✓       ✓   
  NetBSD pax            M    M+P   M+F   M+F    M+F+P 
  busybox               1     1     ✗     ✗       ✗   
  Python                ✗     ✗     ✗     ✗       ✗   
  p7zip                 1    1+P   1+F   1+F    1+F+P 
  7-Zip                 1    1+P   1+F   1+F    1+F+P 
  WinRAR                T     T    T+F   T+F     T+F  
  =================== ===== ===== ===== ====== =======
  
  ✓: file extracted correctly

  W: file extracted correctly, warning about unknown pax attrs

  1: only first part extracted, continuation archive rejected

  Z: only first part extracted, file zero-padded to full size

  P: pax headers extracted as files

  F: extra data extracted as file

  M: continuation archive misread (output malformed)

  T: first part extracted only partially (interrupted by error)

  ✗: archive rejected

As expected, the support for multi-volume archives is poor.  GNU tar
can only extract its own multi-volume format; star can extract both GNU
and its own format.  All other tools error out either on truncated file
or invalid format (especially in case of star formats).

In some cases, the tools can extract parts of the file from both
archives separately, making it possible to manually reconstruct it.
However, e.g. libarchive pads the file to full size (preallocates?),
and WinRAR apparently does not flush output when erroring out.
Furthermore, some tools reject the second and further volumes (e.g. GNU
tar on star formats).

Curious enough, the NetBSD pax tool seems to support split(1)-made
multi-volume archives explicitly (i.e. request further volumes).


Feature matrix
--------------
The following table summarizes the support for most useful formats
and their features.  Some of the earlier results are skipped because
of their unlikely usefulness, e.g. long octet fields since no common
implementation writes them.

Please note that the table is focused on rough usefulness and not
the details.  For example, since volume label has no real implications,
it is considered ✓ as long as the archive is accepted; but some pax
attributes are considered ✓ only if the relevant property is actually
restored.

  =================== = = = = = = = = = = = = = = = = = = = = = = =
  Format              GNU + base-256    pax
  ------------------- ----------------- ---------------------------
  Implementation      p s u m n r l y v p s u g m n t a f x r l v y
  =================== = = = = = = = = = = = = = = = = = = = = = = =
  GNU tar             ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✗ ✓ ✓ ✓ ✓ ✓
  libarchive          ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✗ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✗ ✓
  star                ✓ ✓ ✗ ✗ ✗ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✗ ✓ ✓ ✓
  NetBSD pax          ✓ ✗ ✗ ✗ ✗ ✗ ✓ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✓ ✗ ✗
  busybox             ✓ ✓ ✓ ✓ ✓ ✗ ✗   ✗ ✓ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✓ ✗ ✓
  Python              ✓ ✓ ✓ ✓ ✓ ✓ ✓ ✗ ✗ ✓ ✓ ✓ ✓ ✓ ✓ ✗ ✗ ✗ ✗ ✓ ✓ ✗ ✓
  p7zip               ✓ ✓ ✗ ✓ ✗ ✓ ✗   ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✗ ✓ ✗ ✗
  7-Zip               ✓ ✓   ✓ ✓ ✓ ✗   ✗ ✗ ✗     ✗ ✗ ✗       ✗ ✓ ✗ ✗
  WinRAR              ✓ ✓   ✗ ✗ ✗ ✓ ✗ ✗ ✓ ✓     ✗ ✗ ✗       ✗ ✓ ✗ ✓
  =================== = = = = = = = = = = = = = = = = = = = = = = =

  p: long paths

  s: extended size range

  u: extended UID/GID range

  g: extended user/group names

  m: extended mtime range

  n: negative mtime

  t: extended timestamps (atime, ctime)

  a: ACLs

  f: file flags

  x: extended attributes

  r: sparse files

  l: volume label

  y: (GNU tar) does not create stray file for label

  v: multi-volume archives

  y: (pax) does not create stray files for pax attributes


Summary
=======
The ustar format (both in POSIX and pre-POSIX/GNU variant) is widely
supported.  Only few of the tested implementations can distinguish
pre-POSIX ustar archives from GNU archives; modern versions of GNU tar
avoid writing atime/ctime that confuses ustar-based archivers.

The support for pax format is surprisingly weak.  Many archivers extract
pax attributes as regular files without interpreting even the most basic
set.  Some implementations try to combine pax and GNU format extensions
whenever possible to improve compatibility.

Out of the tested implementations, GNU tar, libarchive and star seem
to be state-of-the-art archivers.  The Python tarfile module also
implements a wide range of formats.  BusyBox and 7-Zip seem to have
relatively good support for GNU extensions but not pax.

The best compatibility advise is to use the POSIX ustar format and avoid
any extensions whenever possible.  If long paths are necessary, both
the ustar and the GNU formats are good choices (the latter especially
if the ustar limit is too small).  For files over 8 GiB of size, the GNU
format seems to be the best choice (though it defeats NetBSD pax
already).

Other extended features are going to cause more trouble.  Wider ranges
of user/group information and timestamps are supported unevenly both
in GNU and pax formats.  Technically, the choice of pax there is safer;
however, all the tested implementations simply ignored base-256 values
they could not interpret.  For numeric values, combining pax
and base-256 encodings may improve portability.

Additional timestamps (atime, ctime), ACLs, file flags and extended
attributes require the use of pax format.  They are only supported
by GNU tar, libarchive and star.  File flags are limited to libarchive
and star, with both implementations being only partially compatible.

Sparse files are supported by most of the implementations in GNU format,
and by a few less in pax format (all three versions of GNU extension
having the same level of support).  For portability, it's best to avoid
using this feature and instead store the files zero-padded and rely
on compression and automatic hole detection.

Volume labels are best avoided in the GNU format as they cause a few
tools to reject the archives altogether.  They are entirely safe
in the pax format (if you ignore the usual problem of stray files).

Multi-volume archives are barely supported and inconvenient to use.
If there is a necessity of splitting the archive, use of split(1) is
strongly preferable.

To summarize, if your main concern are long paths and/or large files,
the GNU format is the best choice.  Extended file metadata may require
using the pax format (possibly combined with base-256 whenever
possible); however, using it reduces compatibility with long paths
and may cause extraneous files to be created.  Volume label can be used
safely if pax format is already used.  All other features should be
avoided.

Judging by the test results, the most portability could be achieved by:

- using strict POSIX ustar format whenever possible,

- using GNU format for long paths (that do not fix in ustar format),

- using base-256 (+ pax if already used) encoding for large files,

- using pax (+ octal or base-256) for high-range/precision timestamps
  and user/group identifiers,

- using pax attributes for extended metadata and/or volume label.

However, whether such a profile could be reliably used would require
further testing, e.g. for interoperability between pax headers
and GNU-style long paths.


References
==========

.. [#GNUTAR] GNU Tar
   (https://www.gnu.org/software/tar/)

.. [#LIBARCHIVE] libarchive
   (http://www.libarchive.org/)

.. [#STAR] star
   (https://sourceforge.net/projects/s-tar/)

.. [#NETBSD-PAX] NetBSD CVS: src/bin/pax/
   (http://cvsweb.netbsd.org/bsdweb.cgi/src/bin/pax/)

.. [#BUSYBOX] BusyBox
   (https://www.busybox.net)

.. [#PYTHON-TARFILE] Python 3.7: tarfile
   (https://docs.python.org/3.7/library/tarfile.html)

.. [#P7ZIP] P7ZIP
   (http://p7zip.sourceforge.net/)

.. [#7ZIP] 7-Zip
   (https://www.7-zip.org/)

.. [#WINRAR] WinRAR
   (https://rarlab.com/)

.. [#TAR-TEST-INPUTS] Test inputs for tar implementation compatibility
   check
   (https://github.com/mgorny/tar-test-inputs)

.. [#TAR.5] tar(5) manual page
   (https://github.com/libarchive/libarchive/wiki/ManPageTar5)
