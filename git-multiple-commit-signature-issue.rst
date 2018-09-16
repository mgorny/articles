======================================================================
Attacks on git signature verification via crafting multiple signatures
======================================================================
:Author: Michał Górny
:Date: 2018-08-14
:Version: 1.0
:Copyright: http://creativecommons.org/licenses/by/3.0/


.. contents::


Abstract
========
This article shortly explains the git weaknesses regarding handling
commits and tags with multiple OpenPGP signatures.  The method of
creating such commits and tags is presented, and the results of using
them are described and analyzed.


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


Git tag signatures
------------------
Independently of underlying commits, git tags also can contain OpenPGP
signatures.  Signed tags are created using ``git tag --sign`` (``-s``).

For a signed tag, the OpenPGP ASCII-armored signature is appended to
the commit object.  In this regard, the tag resembles an inline OpenPGP
signed message, except for missing the message header line.  An example
git signed tag follows::

    object ed513bf746c9d4d609ccec85230be1793c197b51
    type commit
    tag good-tag
    tagger Michał Górny <mgorny@gentoo.org> 1534251684 +0200

    Good signed tag
    -----BEGIN PGP SIGNATURE-----

    iQKTBAABCgB9FiEEXr8g+Zb7PCLMb8pAur8dX/jIEQoFAlty0qpfFIAAAAAALgAo
    aXNzdWVyLWZwckBub3RhdGlvbnMub3BlbnBncC5maWZ0aGhvcnNlbWFuLm5ldDVF
    QkYyMEY5OTZGQjNDMjJDQzZGQ0E0MEJBQkYxRDVGRjhDODExMEEACgkQur8dX/jI
    EQpvKxAA7SrbK2OZ5An20vVSsMQRNrEcxVJahcZUNF7DPVywO3WyBmgnPis7ZtgQ
    CReKe/7s4kMhRH3JUaUCZXaHuZxCQgwCp/yQudDtyL2Z2InEbN9bhjtps58RHaNr
    NIGrOiRobMa0DxHmbLjV3QhR8LMQL4FX/vp5ujkZxQZpPIHlVyv0sxyeDKayVbNV
    eqX1ygh3AiZtU7j9d7Vk1A5NyTbreeqP0AGSgJazYY0YPxPIevRq6IKhGsewmt/V
    d3hkQG16g5FCmGYmkbjgij9jjWKLvQeAcBj4r72HFcbQAB09QTitgjwPQT3KI9ev
    Ob1fhn7PLOyh3zF1HpBVa3z5HnMfvJws5DC5RJz94Zy4+CF4cjlDjX2YE/s7Y+EI
    eVvGjKbAE4a9s+mSV+Qkt/8AY8ZKKwWucfvtMrzKdhb5icHA/nPRdVOgElS9cBBM
    UiXxAXHc1n6ILQQV7s8oSwJDXRscdln/gOF5VXM/O6eNXP7d0672dUHaIwNWevKy
    nP0rdgIbwNtQSpvTVIT2O2Mei7Brd7Dt/MgDwHNPc3jHpa2xdhK4Ki9Lh38wRu0Q
    PQpfvXTohoYbhc31OnYSR7RWX5/IGb441Rglbt/xRCvpbXC8D9ctkZmU/rumu3KO
    utPujUAdoVxcsbVzj1Ri8Rx+swWy9DWDotRPKRRVip+xww4kRWY=
    =whlN
    -----END PGP SIGNATURE-----

This signature can be verified by moving the signature into a separate
file (making it detached) and stripping it off the original file.


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

The output is processed through scanning it for a number of status
codes.  The code as of 2018-08-03 (from the git repository) uses
the following array::

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
identifier and UID.


Git tag signature verification
------------------------------
Similarly to commit signature verification, tag verification also uses
``gpg --verify`` with ``--status-fd`` option.  However, it does not
process its output completely and merely matches it for the presence
of ``GOODSIG`` status.


Attack on commit signatures
===========================

Summary
-------
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
commit signature is in user's keyring or it isn't, and whether it's
trusted by the user (presuming the trusted key is), the signature-
related format strings work as listed in the table:

  ======= ================ ============= ===========
  Format  Not in keyring   Untrusted     Trusted
  ======= ================ ============= ===========
  ``%G?`` E (unverifiable) U (untrusted) B (bad)
  ``%GK`` malicious key    trusted key   trusted key
  ``%GS`` trusted key      trusted key   trusted key
  ======= ================ ============= ===========


Impact
------
Since in no case the result is reported as good, this issue does not
impact the result of ``--verify-signatures`` option.  However, it could
be exploited to confuse custom signature verification scripts using
the format strings.

The worst possible case occurs when the attacker's key is present
in user's keyring.  This could occur e.g. if the key is present
on the keyservers and the user is using ``auto-key-retrieve`` GnuPG
option, or if the key was used for some legitimate purpose before.
In this scenario, the second signature downgrades the classification
from ‘B’ (bad signature) to ‘U’ (untrusted key).  Given that it is
common for users to verify using untrusted keys, the attack could easily
be overlooked.

What is even worse, the ``%GK`` and ``%GS`` formats both report
on the other key rather than the one reported as untrusted.  This means
that if a script accepts untrusted signatures after verifying the key
identifier as reported by ``%GK``, the script would wrongly consider
the commit correctly signed by the trusted key.


Detailed outline of test case
-----------------------------
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


Attack on tag signatures
========================

Summary
-------
The attack is based on replacing the original tag object with a crafted
tag.  The crafted tag can contain altered data — usually referencing
a malicious commit.  The tag signature is replaced by a concatenation
of the original signature and an untrusted signature of the updated tag.

Effectively, the crafted tag contains two OpenPGP signatures:

1. The original OpenPGP signature that was made with a trusted key
   but does not correspond to the current data (is bad).

2. The crafted tag signature that was made with an untrusted key but
   is valid.

Upon processing this tag, git fails to account for two signature being
present.  Instead, if the key used by attacker is present in the local
keyring, it assumes that the signature is good and returns successful
verification result.


Impact
------
This attempt can only be exploited if the key used by the attacker is
present in the local keyring.  The result of using two signatures is
not different from the result of replacing the it with a single
untrusted signature.  Therefore, the attack does not expose any
additional weakness beyond git not distinguishing signatures made using
untrusted key.


Detailed outline of test case
-----------------------------
Given a repository with signed tags, the test case can be built
as outlined below:

1. Create a malicious replacement commit for the tag.

2. Obtain the raw data of a signed tag using ``git cat-file -p
   <tag-name>``.

3. Move the ASCII-armored signature of the original tag and store it
   in a regular text file.

4. Strip the signature out of tag file.

5. Verify the correctness of the above steps using ``gpg --verify
   <orig-signature-file> <stripped-tag-file>``.

6. Dearmor the original signature using ``gpg --dearmor
   <orig-signature-file>``.

7. Alter the tag data, e.g. by replacing the object reference with
   the malicious commit identifier.

8. Create a detached (binary) signature for the new commit data using
   ``gpg -u <key-id> --detach-sign <stripped-tag-file>``.

9. Concatenate both signatures and rearmor them using ``cat
   <orig-signature-file> <new-signature-file> | gpg --enarmor``.

10. Add the signature to the new tag file using the original header/
    footer and the base64 armored data from the enarmored file.

11. Inject the crafted commit using ``git hash-object -t tag -w
    <new-tag-file>``.

12. Update the tag using ``git tag -f <tag-name> <new-tag-id>``.
