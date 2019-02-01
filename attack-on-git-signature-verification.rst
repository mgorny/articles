=====================================================================
Attack on git signature verification via crafting multiple signatures
=====================================================================
:Author: Michał Górny
:Date: 2019-01-26
:Version: 1.0
:Copyright: https://creativecommons.org/licenses/by/3.0/


.. contents::


Abstract
========
This article shortly explains the historical git weakness regarding
handling commits with multiple OpenPGP signatures in git older than
v2.20.  The method of creating such commits is presented,
and the results of using them are described and analyzed.


Background
==========

Git commit signatures
---------------------
Git supports including OpenPGP signatures in commit objects.  Signed
commits are normally created using the ``git commit --gpg-sign``
(``-S``) option.

In order to sign the commit, git creates an ASCII-armored detached
signature of the raw commit object.  The signature is afterwards
inserted into the commit object as an additional ``gpgsig`` header.
An example signed commit created using git-2.18.0 follows::

    tree 7abbe04404b7c52c1aa0b4292ae70db4468f09c7
    author Michał Górny <mgorny@gentoo.org> 1533894404 +0200
    committer Michał Górny <mgorny@gentoo.org> 1533894404 +0200
    gpgsig -----BEGIN PGP SIGNATURE-----
     
     iQKTBAABCgB9FiEEXr8g+Zb7PCLMb8pAur8dX/jIEQoFAlttXwpfFIAAAAAALgAo
     aXNzdWVyLWZwckBub3RhdGlvbnMub3BlbnBncC5maWZ0aGhvcnNlbWFuLm5ldDVF
     QkYyMEY5OTZGQjNDMjJDQzZGQ0E0MEJBQkYxRDVGRjhDODExMEEACgkQur8dX/jI
     EQqr9g/8DY3EVjIXI4JbZxFb+lFicMqMNSx64SexNb8HnM5LjEQGr8HmJSRdG3TC
     P+s4wkT/amV9+tfjiLxY78MjG1Zx4OpvweHUwXrKg7b3epz9Q7uzt+2UStjq3yuU
     HmJl3P/NziZdVTTRekQ4AYi2C6ZE/HPn7NBKwdWyrmFBOPijjWgWBvFsVtvkEfzQ
     SCPjpiDOX0RqyF16o6ZjVYatykyT3JSJAcMmL7E6HS8n9wdmJ5k7JXVly5OS3ZUb
     vivUKJRz/3u9+AT0Eju5JaVGbyhL3+2+oZjy1VCWq8xoIveezQ9MDikuSLan1MjF
     JfbXvj7PL4LrVXFajNz8HEnVIwB8QOgfqyyw7MSK4PFUhmplvJ45rj8gNRGI4qMr
     zjJCZxlUcj+qyfWIrGA7QMDXJtZwTB8gNCkJmRutuRMIs//ntlq1qPBvcJMDLOJ9
     jXPB7nG9+X+0XuOXPExPPqBBqB9Vp2165ZDE2jpwfEEE6BEteqDPfwHW9XxsJvvu
     wBBFUQXpxfnQF4SqcVYlb/6eTjBK3xjr+d9sbvWTN4cOBXfrG/0xI7aeuQd8Wwu2
     RoIUtAtEsH3jRpW8Ag8hsee9yf1LPWs7DsXZSShG2391q5719RVJaYHIBvOCmgu3
     JSQqw6+77aXRDHm/8DOBx8y+F3YKmNHJQWx1Gmg2wJ0++kU4nY8=
     =yA4c
     -----END PGP SIGNATURE-----

    Initial commit

In order to verify this signature, git reads the ``gpgsig`` header
and strips it from the commit object.  The remaining part of the commit
object is afterwards verified using the detached signature.


Multiple OpenPGP signatures
---------------------------
The GnuPG implementation of OpenPGP supports creating multiple
signatures of the data.  As of gnupg-2.2.9, this can be accomplished
via providing multiple ``--local-user`` (``-u``) options to one
of the signing commands.

Technically, multiple signatures are created via concatenating multiple
signature packets.  It needs to be noted that only binary concatenation
of the packets is valid.  Concatenated ASCII-armored signatures will
not be handled correctly — they need to be dearmored first,
and rearmored after the concatenation.


Git commit signature verification
---------------------------------
In order to verify signatures, git spawns ``gpg --verify ...``
with the ``--status-fd`` option and processes its machine-oriented
output.  It discards the exit status of GnuPG.

The output is processed by scanning it for a number of status codes.
The code as of 2018-08-03 (from the git repository) uses the following
array::

    static struct {
        char result;
        const char *check;
    } sigcheck_gpg_status[] = {
        { 'G', "\n[GNUPG:] GOODSIG " },
        { 'B', "\n[GNUPG:] BADSIG " },
        { 'U', "\n[GNUPG:] TRUST_NEVER" },
        { 'U', "\n[GNUPG:] TRUST_UNDEFINED" },
        { 'E', "\n[GNUPG:] ERRSIG "},
        { 'X', "\n[GNUPG:] EXPSIG "},
        { 'Y', "\n[GNUPG:] EXPKEYSIG "},
        { 'R', "\n[GNUPG:] REVKEYSIG "},
    };

Git scans the whole buffer for those status strings, in order.  It does
not interrupt the search upon finding one of the strings; therefore
the later statuses override the earlier ones.  Finally, it returns
a structure containing the result code along with appropriate key
identifier and UID.  [#GIT-OLD-CODE]_


Summary
=======
The attack is based on replacing the original commit object with
a crafted commit.  The crafted commit can contain altered data —
for example, the tree reference could be replaced with a tree containing
malicious data.  The commit signature is replaced by a concatenation
of the original signature and an untrusted signature of the updated
commit.

Effectively, the crafted commit contains two OpenPGP signatures:

1. The original OpenPGP signature that was made with a trusted key
   but does not correspond to the current data (is bad).

2. The crafted commit signature that was made with an untrusted key but
   is valid.

Upon processing this commit, git fails to distinguish the two signatures
properly.  Depending on whether the key used to create the crafted
commit signature is in user's keyring, and whether it's trusted
by the user (presuming the trusted key is), the signature-related
format strings work as listed in the table:

  ======= ================ ============= ===========
  Format  Not in keyring   Untrusted     Trusted
  ======= ================ ============= ===========
  ``%G?`` E (unverifiable) U (untrusted) B (bad)
  ``%GK`` malicious key    trusted key   trusted key
  ``%GS`` trusted key      trusted key   trusted key
  ======= ================ ============= ===========


Impact
======
Since in no case the result is reported as good, this issue does not
impact the result of ``--verify-signatures`` option.  However, it could
be exploited to confuse custom signature verification scripts using
the format strings.

The worst possible case occurs when the attacker's key is present
in user's keyring but it is not trusted.  This could occur e.g.
if the key is present on the keyservers and the user is using
``auto-key-retrieve`` GnuPG option, or if the key was used for some
legitimate purpose before.  In this scenario, the second signature
downgrades the classification from ‘B’ (bad signature) to ‘U’ (untrusted
key).  Given that it is common for users to verify using untrusted keys,
the attack could easily be overlooked.  However, this is really no
different from replacing the signature altogether.

The real problem is that the ``%GK`` and ``%GS`` format strings both
report the trusted key data rather than the one reported as untrusted
(and corresponding to ``%G?``).  This means that if a script verifies
trust based on reported key identifer, it would wrongly consider
the commit as correctly signed using the trusted key.


Solution
========
The problem has been resolved upstream via refactoring the status output
processing code to detect multiple exclusive statuses (indicating
multiple signatures present) and explicitly consider the case
unsupported (reported as ``E``).  This fix has been included in v0.20.0.
[#COMMIT-DA6CF1B336]_


Detailed outline of the test case
=================================

Constructing the test case
--------------------------
Given a repository with signed commits, the test case can be built
as outlined below:

1. Create a malicious tree object.  This could be done using low-level
   git commands, or by simply creating a commit, taking its tree object
   ID and discarding it.

2. Obtain the raw data of a signed commit using ``git cat-file -p
   <commit-id>``.

3. Copy the ASCII-armored signature of the original commit (from
   ``gpgsig`` header) and store it in a regular text file.

4. Copy the original commit into new file, stripping the ``gpgsig`` tag.

5. Verify the correctness of the above steps using ``gpg --verify
   <orig-signature-file> <stripped-commit-file>``.

6. Dearmor the original signature using ``gpg --dearmor
   <orig-signature-file>``.

7. Alter the commit data, e.g. by replacing the tree reference with
   the malicious tree object.

8. Create a detached (binary) signature for the new commit data using
   ``gpg -u <key-id> --detach-sign <stripped-commit-file>``.

9. Concatenate both signatures and rearmor them using ``cat
   <orig-signature-file> <new-signature-file> | gpg --enarmor``.

10. Add the ``gpgsig`` header to the new commit file using the original
    header/footer and the base64 armored data from the enarmored file.

11. Inject the crafted commit using ``git hash-object -t commit -w
    <new-commit-file>``.

12. Set the branch to point to the new commit, e.g. using ``git reset
    --hard <new-commit-id>``.


Analysis of git behavior
------------------------
As outlined in `Git commit signature verification`_, git matches
the status output of GnuPG against a set of expected status strings,
in order of definition.  The example status output for the crafted
commit might be::

    [GNUPG:] NEWSIG
    [GNUPG:] KEYEXPIRED 1376950668
    [GNUPG:] KEY_CONSIDERED 3408B1B906EB579B41D9CB0CDF84256885283521 0
    [GNUPG:] KEYEXPIRED 1376950668
    [GNUPG:] KEY_CONSIDERED 3408B1B906EB579B41D9CB0CDF84256885283521 0
    [GNUPG:] BADSIG BABF1D5FF8C8110A Michał Górny (Gentoo) <mgorny@gentoo.org>
    [GNUPG:] VERIFICATION_COMPLIANCE_MODE 23
    [GNUPG:] NEWSIG
    [GNUPG:] KEY_CONSIDERED 55642983197252C35550375FBBC7E6E002FE74E8 0
    [GNUPG:] SIG_ID 2Jjh1WK6tNxktx0Ijiy+rdV9VGk 2018-08-14 1534241226
    [GNUPG:] KEY_CONSIDERED 55642983197252C35550375FBBC7E6E002FE74E8 0
    [GNUPG:] GOODSIG BBC7E6E002FE74E8 Example key <example@example.com>
    [GNUPG:] NOTATION_NAME issuer-fpr@notations.openpgp.fifthhorseman.net
    [GNUPG:] NOTATION_FLAGS 0 1
    [GNUPG:] NOTATION_DATA 55642983197252C35550375FBBC7E6E002FE74E8
    [GNUPG:] VALIDSIG 55642983197252C35550375FBBC7E6E002FE74E8 2018-08-14 1534241226 0 4 0 1 10 00 55642983197252C35550375FBBC7E6E002FE74E8
    [GNUPG:] KEY_CONSIDERED 55642983197252C35550375FBBC7E6E002FE74E8 0
    [GNUPG:] TRUST_UNDEFINED 0 pgp
    [GNUPG:] VERIFICATION_COMPLIANCE_MODE 23

Note that GnuPG outputs status for each of the signatures separately,
prefixing each with ``NEWSIG`` status.  However, git does not support
this status.  Instead, it assumes that the output will refer to a single
signature only.

If we analyze the git behavior, it looks for ``GOODSIG`` status first.
If the attacker's key is present in the local keyring, this line will
be present and git will initially set the signing key and UID to it.
However, this does not really matter since other statuses will override
it.

The next match is for ``BADSIG``.  This one is always present due to
the original signature.  Again, git obtains the key identifier and UID
from it and overrides the previous values.

Afterwards, git matches ``TRUST_*`` statuses.  One of them will match
if the attacker's key is present in keyring but it is not trusted.  This
overrides the check result but since those statuses do not carry a key
ID or UID, those values are left over from the previous check.

Finally, git matches a number of negative statuses starting with
``ERRSIG``.  It is present if the attacker's key is not found
in the local keyring, and it overrides the previous status.  However, it
carries only the key ID but not UID, so it overrides only the former.

Therefore, the check result (``%G?``) will represent either untrusted
key (``U``) or verification error (``E``).  However, since neither
of those statuses provides UID, the UID previously obtained from
``BADSIG`` will be returned instead.  Furthermore, since ``TRUST_*``
does not contain key identifier, the one from ``BADSIG`` will also be
preserved in the untrusted branch.


References
==========
.. [#GIT-OLD-CODE] gpg-interface.c @ 1e7adb9 (2018-07-18)
   (https://github.com/git/git/blob/1e7adb97566bff7d3431ce64b8d0d854a6863ed5/gpg-interface.c#L78)

.. [#COMMIT-DA6CF1B336] gpg-interface.c: detect and reject multiple
   signatures on commits
   (https://github.com/git/git/commit/da6cf1b3360eefdce3dbde7632eca57177327f37)


Comments
========
The comments to this article are maintained as part of the relevant
blog entry: `Attack on git signature verification via crafting multiple
signatures`_.

.. _`Attack on git signature verification via crafting multiple signatures`:
   https://blogs.gentoo.org/mgorny/2019/01/26/attack-on-git-signature-verification-via-crafting-multiple-signatures/#comments
