=====================
verify-sig by example
=====================
:Author: Michał Górny
:Date: 2022-02-20
:Version: 1.0
:Copyright: https://creativecommons.org/licenses/by/4.0/


.. contents::


Introduction to verify-sig.eclass
=================================
The ``verify-sig.eclass`` provides logic to verify the *authenticity*
of distfiles using the signatures provided upstream.  It is meant
as an auxiliary mechanism that helps developers perform version bumps.
While it can be enabled and used by users, Manifests remain the primary
method of verifying distfiles.

While the eclass provides a few functions, the ebuilds rarely need
to use more than one of them.  For this reason, this document focuses
on providing example ebuilds for specific use cases.  The majority
of the eclass consumers are using OpenPGP (`RFC 4880`_) signatures,
and therefore OpenPGP is used as the baseline solution for examples.
The final section is dedicated to using other providers.


OpenPGP signature verification
==============================

Prerequisite: an OpenPGP key package
------------------------------------
In order to be able to test OpenPGP signatures, the appropriate OpenPGP
public keys need to be available first.  These keys are normally
installed via a ``sec-keys/openpgp-keys-*`` package.

The purpose of such a package is to fetch one or more OpenPGP keys,
combine them into a single file and install it into
``/usr/share/openpgp-keys``.  The keys can use either the binary
or the ASCII-armored OpenPGP format.  Both formats permit multiple keys
to be trivially concatenated.

Ideally, the keys should be fetched from upstream website.  If upstream
does not host explicit key files, another source can be used: WKD URLs,
keybase.io_, public keyserver URLs.  However, it needs to be noted that
for GnuPG to work correctly, the key needs to include UIDs.

The verify-sig mechanics do not provide any way to verify
the authenticity of installed OpenPGP keys.  The maintainer of the key
package is responsible for ensuring that the authentic keys are used.

Since these packages install key files only, normally they are added
with a complete set of stable keywords.

.. code-block:: bash

    # Copyright 2022 Gentoo Authors
    # Distributed under the terms of the GNU General Public License v2

    EAPI=7

    DESCRIPTION="OpenPGP keys used to sign Django releases"
    HOMEPAGE="https://www.djangoproject.com/download/"
    SRC_URI="
        https://keys.openpgp.org/vks/v1/by-fingerprint/FE5FB63876A1D718A8C67556E17DF5C82B4F9D00
            -> FE5FB63876A1D718A8C67556E17DF5C82B4F9D00.asc
        https://keybase.io/felixx/pgp_keys.asc?fingerprint=abb2c2a8cd01f1613618b70d2ef56372ba48cd1b
            -> ABB2C2A8CD01F1613618B70D2EF56372BA48CD1B.asc
    "
    S=${WORKDIR}

    LICENSE="public-domain"
    SLOT="0"
    KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"

    src_install() {
        local files=( ${A} )
        insinto /usr/share/openpgp-keys
        newins - django.asc < <(cat "${files[@]/#/${DISTDIR}/}")
    }


Verifying detached signatures
-----------------------------
Detached signatures are separate files, usually suffixed ``.asc`` or
``.sig`` that contain signatures for the respective distfiles.

To verify package using detached signatures, the ebuild needs to:

1. Add the signature files to ``SRC_URI``.

2. Add the package providing the public key to ``BDEPEND``.

3. Specify the key file to use via ``VERIFY_SIG_OPENPGP_KEY_PATH``.

The ``src_unpack`` implementation exported by the eclass takes care
of adding a ``verify-sig`` USE flag and verifying all files
from ``SRC_URI`` when it is enabled.

.. code-block:: bash

    EAPI=8

    inherit verify-sig

    SRC_URI="
        https://libvirt.org/sources/${P}.tar.xz
        verify-sig? ( https://libvirt.org/sources/${P}.tar.xz.asc )
    "

    BDEPEND="
        verify-sig? ( sec-keys/openpgp-keys-libvirt )
    "

    VERIFY_SIG_OPENPGP_KEY_PATH=${BROOT}/usr/share/openpgp-keys/libvirt.org.asc


Combination of signed and unsigned files
----------------------------------------
The default implementation of ``src_unpack`` requires all distfiles
to be accompanied by detached signatures.  When some of the distfiles
(e.g. Gentoo patchsets) are not PGP-signed, the ebuild needs to override
``src_unpack`` and call ``verify-sig_verify_detached`` explicitly
for all files that need to be verified.

The function's synopsis is::

    verify-sig_verify_detached <file> <signature-file> [<key>]

*File* is the file to verify, *signature-file* is the file containing
the detached signature, *key* is the public key file.  If *key* is not
specified, ``VERIFY_SIG_OPENPGP_KEY_PATH`` is used.

.. code-block:: bash

    EAPI=8

    inherit verify-sig

    SRC_URI="
        https://www.python.org/ftp/python/${PV%%_*}/${MY_P}.tar.xz
        https://dev.gentoo.org/~mgorny/dist/python/${PATCHSET}.tar.xz
        verify-sig? (
            https://www.python.org/ftp/python/${PV%%_*}/${MY_P}.tar.xz.asc
        )
    "

    BDEPEND="
        verify-sig? ( sec-keys/openpgp-keys-python )
    "

    VERIFY_SIG_OPENPGP_KEY_PATH=${BROOT}/usr/share/openpgp-keys/python.org.asc

    src_unpack() {
        if use verify-sig; then
            verify-sig_verify_detached "${DISTDIR}"/${MY_P}.tar.xz{,.asc}
        fi
        default
    }


Verifying using a checksum file with an inline signature
--------------------------------------------------------
Rather than signing individual distfiles, some projects instead supply
a signed checksum file.  The hashes contained in this file can be used
to verify the *integrity* of distfiles.  However, if the checksum file
itself is signed, it can be used to assert the *authenticity*
of distfiles as well.

An example checksum file with multiple algorithms and an inline
signature follows:

.. code-block::

    -----BEGIN PGP SIGNED MESSAGE-----
    Hash: SHA256

    [...]

    MD5 checksums
    =============

    a86339c0e87241597afa8744704d9965  Django-4.0.2.tar.gz
    81bb12a26b4c2081ca491c4902bddef9  Django-4.0.2-py3-none-any.whl

    SHA1 checksums
    ==============

    b671dd5cb40814abb89953ce63db872036a7fb77  Django-4.0.2.tar.gz
    163fa6da31e4f191ad06b749093703e019b30768  Django-4.0.2-py3-none-any.whl

    SHA256 checksums
    ================

    110fb58fb12eca59e072ad59fc42d771cd642dd7a2f2416582aa9da7a8ef954a  Django-4.0.2.tar.gz
    996495c58bff749232426c88726d8cd38d24c94d7c1d80835aafffa9bc52985a  Django-4.0.2-py3-none-any.whl
    -----BEGIN PGP SIGNATURE-----

    iQJPBAEBCAA5FiEEq7LCqM0B8WE2GLcNLvVjcrpIzRsFAmH42nMbHGZlbGlzaWFr
    [...]
    -----END PGP SIGNATURE-----

The ``verify-sig_verify_signed_checksums`` can be used to verify
the distfiles against this file.  Its synopsis is::

    verify-sig_verify_signed_checksums <checksum-file> <algo> <files> [<key>]

*Checksum file* specifies the file with the signatures.  *Algo*
specifies the signature algorithm used.  *Files* is a space-separated
list (passed as a single argument, i.e. quoted) of files to verify.
As before, *key* specifies the key file and defaults
to ``VERIFY_SIG_OPENPGP_KEY_PATH``.

The checksum file must contain a valid inline signature.  Only data
covered by the signature is processed.  Lines that do not resemble
checksums in the specified algorithm are ignored.  The checksum file
can also contain checksums using other algorithms, as long as they are
of different length than the one that is being tested.

For verification to succeed, all specified *files* must be present
in the checksum file and have matching hashes.  The file paths must
match exactly, therefore normally it is necessary to ensure that they
are present in the current working directory.

.. code-block:: bash

    EAPI=8

    inherit verify-sig

    SRC_URI="
        https://media.djangoproject.com/releases/$(ver_cut 1-2)/${MY_P}.tar.gz
        verify-sig? ( https://media.djangoproject.com/pgp/${MY_P}.checksum.txt )
    "

    BDEPEND="
        verify-sig? ( >=sec-keys/openpgp-keys-django-20201201 )
    "

    VERIFY_SIG_OPENPGP_KEY_PATH=${BROOT}/usr/share/openpgp-keys/django.asc

    src_unpack() {
        if use verify-sig; then
            cd "${DISTDIR}" || die
            verify-sig_verify_signed_checksums \
                "${MY_P}.checksum.txt" sha256 "${MY_P}.tar.gz"
            cd "${WORKDIR}" || die
        fi

        default
    }


Verifying using a checksum file with a detached signature
---------------------------------------------------------
The final variant supported by the eclass is a checksum file that is
signed using a detached signature.  In this case the checksum file
contains only file hashes, and there is an additional ``.asc``-
or ``.sig``-suffixed file with the OpenPGP signature.  An example
checksum file could look like:

.. code-block::

    94ccd60e04e558f33be73032bc84ea241660f92f58cfb88789bda6893739e31c tor-0.4.6.10.tar.gz

This is similar to the previous variant, except that the ebuilds need
to explicitly perform two operations:

1. Verify the checksum file against the detached signature.  This is
   done using ``verify-sig_verify_detached`` as with detached distfile
   signatures.

2. Verify the distfiles against the checksum file.  This is done using
   ``verify-sig_verify_unsigned_checksums``.

the ``verify-sig_verify_unsigned_checksums`` has the following
synopsis::

    verify-sig_verify_unsigned_checksums <checksum-file> <algo> <files>

*Checksum file* specifies the file with the signatures.  *Algo*
specifies the signature algorithm used.  *Files* is a space-separated
list (passed as a single argument, i.e. quoted) of files to verify.

.. code-block:: bash

    EAPI=8

    inherit verify-sig

    SRC_URI="
        https://www.torproject.org/dist/${MY_PF}.tar.gz
        verify-sig? (
            https://dist.torproject.org/${MY_PF}.tar.gz.sha256sum
            https://dist.torproject.org/${MY_PF}.tar.gz.sha256sum.asc
        )
    "

    BDEPEND="verify-sig? ( >=sec-keys/openpgp-keys-tor-20220216 )"

    VERIFY_SIG_OPENPGP_KEY_PATH=${BROOT}/usr/share/openpgp-keys/torproject.org.asc

    src_unpack() {
        if use verify-sig; then
            cd "${DISTDIR}" || die
            verify-sig_verify_detached ${MY_PF}.tar.gz.sha256sum{,.asc}
            verify-sig_verify_unsigned_checksums \
                ${MY_PF}.tar.gz.sha256sum sha256 ${MY_PF}.tar.gz
            cd "${WORKDIR}" || die
        fi

        default
    }


Other signature providers
=========================

Enabling other signature provider
---------------------------------
The signature provider used by the eclass can be configured using
the ``VERIFY_SIG_METHOD`` variable.  This variable needs to be set
before inheriting the eclass to ensure that correct dependencies are
generated.

The eclass exposes the same API for all signature providers.  However,
not all providers are guaranteed support (or require) all the functions.
For historical reasons, some variables mention OpenPGP but are also
used with other providers, e.g. ``VERIFY_SIG_OPENPGP_KEY_PATH``
specifies the key path for any provider.


Using signify-based signatures
------------------------------
Signify_ is the tool used to sign OpenBSD releases.  For signify-based
signatures:

1. ``VERIFY_SIG_METHOD`` needs to be set to ``signify``.

2. Keys are packaged as ``sec-keys/signify-keys-*`` and installed
   into ``/usr/share/signify-keys``.

3. Keys are usually rotated upstream, it therefore usually makes sense
   to add a revision to the filename and slot the package.

4. The tool does not deal with symlinks used in ``DISTDIR`` well,
   so the files need to be copied elsewhere before the verification.

An example signify key package follows.

.. code-block:: bash

    # Copyright 2022 Gentoo Authors
    # Distributed under the terms of the GNU General Public License v2

    EAPI=8

    EGIT_COMMIT=cb113fe442f84ab7d4ac95b44c49812001e32350
    MY_P=${P#signify-keys-}
    DESCRIPTION="Signify keys used to sign signify portable releases"
    HOMEPAGE="https://github.com/aperezdc/signify"
    SRC_URI="
        https://github.com/aperezdc/signify/raw/${EGIT_COMMIT}/keys/signifyportable.pub
            -> ${MY_P}.pub
    "
    S="${WORKDIR}"

    LICENSE="public-domain"
    SLOT="${PV}"
    KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"

    src_install() {
        insinto /usr/share/signify-keys
        doins "${DISTDIR}/${MY_P}.pub"
    }

An example signed checksum file looks like the following:

.. code-block::

    untrusted comment: verify with signifyportable.pub
    RWRQFCY809DUoRjNsQeqNhEUJJ2/utG430CzFa1JNu9J/CFPoqPP7RS69/feSTs0rkIbJpbHMauNmy6dac2aXePVeeBQn5EprQc=
    SHA256 (signify-30.tar.xz) = f68406c3085ef902e85500e6c0b90e4c3f56347e5efffc0da7b6fb47803c8686

An example package using signify-style signed checksums.

.. code-block:: bash

    EAPI=8

    VERIFY_SIG_METHOD="signify"
    inherit verify-sig

    SRC_URI="
        https://github.com/aperezdc/${PN}/releases/download/v${PV}/${P}.tar.xz
        verify-sig? (
            https://github.com/aperezdc/${PN}/releases/download/v${PV}/SHA256.sig
                -> ${P}.sha.sig
        )
    "

    BDEPEND="verify-sig? ( sec-keys/signify-keys-signify )"

    VERIFY_SIG_OPENPGP_KEY_PATH="${BROOT}/usr/share/signify-keys/${P}.pub"

    src_unpack() {
        if use verify-sig; then
            cp "${DISTDIR}"/${P}.{sha.sig,tar.xz} . || die
            verify-sig_verify_signed_checksums \
                ${P}.sha.sig sha256 ${P}.tar.xz
        fi
        unpack "${P}.tar.xz"
    }


.. _RFC 4880: https://datatracker.ietf.org/doc/html/rfc4880
.. _keybase.io: https://www.keybase.io/
.. _signify: https://flak.tedunangst.com/post/signify
