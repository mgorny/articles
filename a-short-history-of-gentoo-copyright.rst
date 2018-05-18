===================================
A short history of Gentoo copyright
===================================
:Author: Michał Górny
:Date: 2018-05-18
:Version: 1.0
:Copyright: http://creativecommons.org/licenses/by/3.0/


.. contents::


Preamble
========
As part of the recent effort into forming a new copyright policy for
Gentoo, a research into the historical status has been conducted.  We've
tried to establish all the key events regarding the topic, as well
as the reasoning behind the existing policy.  I would like to shortly
note the history based on the evidence discovered by Robin H. Johnson,
Ulrich Müller and myself.


Source of copyright ownership policy
====================================
The custom of assigning the copyright to Gentoo seems to date back to
its early days.  It is already present in the first known commit to
the gentoo-x86 CVS repository [#FIRST-COMMIT]_::

    # Copyright 1999-2000 Gentoo Technologies, Inc.
    # Distributed under the terms of the GNU General Public License, v2 or later
    # $header$

It seems that this has been followed through since then.  Apparently
at least a few times contributors have asked about this.  Daniel
Robbins' post from 2003-08-21 seems to shed more light on this:

  What we are doing now began way back when we figured out that slapping
  a "Copyright 2000 Gentoo Technologies, Inc." allowed us to comply with
  the GPL and get back to coding.  That's all there is to our current
  "policy," folks.  [...]  [#ROBBINS-20030821]_

In the same mail, Daniel indicates that he would like the copyright to
be assigned both to Gentoo Technologies and to the submitter
simultaneously.  However, it seems that this idea never took off.  This
particular thread has been referenced in Junuary 2004, and Jon Portnoy's
reply from 2004-01-07 seems to provide the explanation:

  In another post in that thread, he [Daniel] said that he had consulted
  with his lawyer and dual copyrights were, indeed, a bad idea.
  [#PORTNOY]_

However, the post mentioned is nowhere to be found in the archives.


Relicensing to GPL-2
====================
The Gentoo ebuild repository was initially licensed ‘GPL, v2 or later’,
as seen in the header above.  The ‘or later’ part was removed later.
The first commit using pure ‘GPL v2’ seems to be dated 2002-02-09
[#GPLV2-COMMIT]_.  It uses the following heading::

    # Copyright 1999-2002 Gentoo Technologies, Inc.
    # Distributed under the terms of the GNU General Public License v2

Afterwards, the ebuilds were slowly transitioned to new license as part
of other changes.  It seems that major relicensing of ebuilds was done
in October of 2002 but a handful of GPL-2+ ebuilds remained,
and occassionally new ebuilds allowing newer GPL versions were
committed.  The last GPL-2+ ebuilds were cleaned up in 2012.  Some
of the auxiliary files (e.g. init.d scripts) still use GPL-2+ today.

The closest explanation preceding the relicensing seems to be
Daniel Robbins' post from 2002-02-07 which states:

  [...]  It does allow me to tweak the GPL part of the license to be "v2
  only", which has been something that I've been meaning to do for a
  while since I like the GPL but don't automatically trust future GPL
  licenses.  [...]  [#ROBBINS-20020207]_

Back then, GPL-3 was not even in the making for over three more years.
Its final version has been published mid-2007 [#GPLV3-GUIDE]_.  Gentoo
has not yet made any decisive move with regards to GPL-3.


Copyright assignment forms
==========================
The early Gentoo copyright assignments did not seem to have been backed
by any paperwork.  However, based on the evidence collected, it seems
that Gentoo recruiters were collecting copyright assignment forms
in the period between December 2003 and July 2004.  Sadly, they failed
to create a single archive for them, and we have been able only to find
some of them scattered over various locations.

There is no clear public evidence as to the event of creating copyright
forms used by Gentoo.  The first copyright form published
on the website is dated 2003-12-09 [#COPY-FORM]_.  According to
a long-time Gentoo developer, it might have been created in relation
to the activities of the recent Zynot fork [#ZYNOT]_.

A letter archived at 2003-10-30 [#LETTER-TO-ZYNOT]_ indicates that
Gentoo Technologies were seeking action against apparent copyright
violation on the side of Zynot.  Sadly, the only date on the letter
is the deadline of 2003-09-12, and the referenced code has not been
archived.  However, it seems a plausible explanation that if Gentoo were
to seek legal action against copyright violations, it would try
to collect copyright forms to back its claims.

By the end of June 2004, Trustees started discussing problems with
the copyright forms in use.  The best list of the claims seems to be
found in Kurt Lieber's mail dated 2004-06-29:

  [...]

  Our copyright assignment doc needs to change.  Specific problems with
  it:

  * It claims ownership of developer hard drives "...or computer media
    relating to the Work.")
  * It says "Gentoo Technologies" instead of "Gentoo Foundation"
  * It is completely unenforceable for any user (non-dev) that submits
    something to bugzilla and/or submissions@g.o.  (we're not
    requiring them to sign this doc, so it's not enforceable)
  * Because we allow the storage things like kernel patches, etc.
    for which we do not own the copyright, in CVS (in the files/
    directories), it shows that we're selectively enforcing the
    copyright assignment.  In the past, this has often resulted
    in the entire document being tossed in court.
  * It is questionable whether or not we have any legal right to enforce
    copyright claims for non-US devs.  They're not US citizens, so it's
    not clear if they're subject to US copyright
    restrictions/assignments.
  * [...]  [#LIEBER-20040629]_

This was followed by a related thread from Deedra Waters on 2004-07-01:

  [...]

  With all the questions being raised now about the copyright assignment
  form, should I stop asking people to sign the current form as they
  come in?  The reason I ask this is because if we create a new form,
  everyone will have to sign that form regardless.

  If the current form isn't enforceable, then having people sign it
  doesn't really do us much good, on top of that, we also need to find
  out the rules behind minors signing copyright forms. Currently, we
  have a lot of devs who are under 18 and I can think of a couple
  of devs who are under 18 who have signed this form.

  [...]  [#WATERS-20040701]_

Apparently, at this point copyright forms stopped being requested.
The topic of updating the form continued to appear on the Trustee agenda
afterwards [#200410-STATUS-UPDATE]_.  However, it doesn't seem that
a new copyright policy was ever actually created.

The only update done to the copyright form was to change the assignee
to Gentoo Foundation which happend on 2006-08-23
[#COPY-FORM-FOUNDATION]_.  It has eventually been removed on 2007-01-27,
along with the policy [#COPY-FORM-RM]_.  A comment made by Bryan
Østergaard on bug #140286 indicates that:

  Looks like all these issues are already fixed but as we haven't used
  the copyright-assignment doc for 2 years at least, I've cvs rm'ed it
  now. If we should ever need it again it can be restored from attic.
  [#BUG-140286]_

Most of the forms that we were able to collect come from a single mail
archive dated 2004-03-24.  It contained unique forms for around 40
individuals, earliest dated 2003-12-29.  The newest copyright form found
(on Bugzilla) was dated 2004-06-02.  It is probable that there were more
copyright forms sent in the second quarter of 2004.

Based on the data available to us, we have been able to verify age
on less than 20 of the available forms, and found only one case
of the form being signed by a person below the age of maturity. Some
of the developer names make it possible that they were signed by non-US
citizens.

It seems that while we always required the copyright to be assigned
to Gentoo, trying to back that up with written contracts was only
a short-lived experiment.  It is unclear how many Gentoo developers have
actually signed them.  However, it is clear that most of the current
Gentoo developers have never heard of them, and that most of the current
Gentoo code is not covered by them.


Transfer of copyright to the Foundation
=======================================
All events presented so far have started in the days when Gentoo
Technologies, Inc. was still relevant.  The Gentoo Foundation was
founded on 2004-05-28 [#FOUNDATION-AOI]_.  One month later, the first
commit updating copyright notice to Gentoo Foundation was made
[#FOUNDATION-COPY-COMMIT]_.

As for the events following, I'd like to quote the timeline made by
Robin H. Johnson in the work-in-progress Copyright Policy
draft:

  * 2005-05-19: Gentoo Technologies, Inc. files an **Assignment of
    Copyright** document, signed by Daniel Robbins, which transfers any
    copyrights held by *Gentoo Technologies, Inc.* over `All files to
    which Gentoo Technologies, Inc. may hold the copyright that existed
    in the Gentoo Concurrent Versions System (CVS) Repositories as of 25
    June 2004`.

  * 2005-06-13: *Gentoo Technologies, Inc.* files a **recordation of
    copyright** with the United States Copyright Office, signed by
    Daniel Robbins, President.  The copyright is asserted over `Gentoo
    Concurrent Versions System (CVS) Repositories as of 25 June 2004`.

  * 2005-06-13: *Gentoo Technologies, Inc.* provides a **Release from
    Contract Requirements** document, signed by Daniel Robbins.  The
    complete body of the document is as follows:

      Gentoo Technologies, Inc. does hereby release all individuals who
      have signed the contract known as the "Gentoo Technologies, Inc.
      Copyright Assignment Form" from any future duties and obligations
      of these individuals associated with that contract.  As of this
      date any provision of that contract requiring any future duties is
      hereby nullified.

  [#NEW-POLICY-DRAFT]_


Copyright of user contributions
===============================

The copyright of all user-contributed ebuilds in the Gentoo repository
is assigned to the Gentoo Foundation.  Only a handful of ebuilds express
additional copyrights over external code fragments.  However, it is
unclear how many users have *willingly* attributed the copyright
to Gentoo, and how many did that only because otherwise they could not
contribute.

RepoMan have been enforcing the required copyright notice since
2003-10-02 [#REPOMAN-COPY]_.  It is present in template files
in the repository and in integrations for major editors.  It seems that
Gentoo developers were always required to enforce the copyright
assignment.  Citing another Daniel Robbins' post from 2002-02-07:

  All ebuilds should be Copyrighted by Gentoo Technologies, Inc.
  or should generally not be put on Portage.  [...]
  [#ROBBINS-20020207-2]_

They were historical cases of users withdrawing their contributions upon
being required to transfer the copyright to Gentoo.  Furthermore, there
was at least a single case of proxied maintainer reusing a third-party
ebuild and changing the copyright notice without obtaining the owner's
agreement (this has been discovered in time, and it has not been
merged).  However, there is no way to know if developers haven't
unilaterally changed copyrights on user submissions in the past.


The future
==========

Three main points were made in favor of copyright assignments so far:

1. They allowed Gentoo Technologies to unilaterally change the license.

2. They technically allowed Gentoo to pursue copyright violations for
   any of the code.

3. They made code reuse simpler due to not requiring tracking
   of copyrights.

However, the points brought in the earlier sections make the Gentoo
implementation of copyright assignment doubtful at least.  It has caused
us to reject some contributions (not a meaningful amount, though)
and raised some doubt as to the actual copyright owners in our code.
Most importantly, it has been pointed out that the full assignment
as used by Gentoo is not permitted by the laws of most of the EU
countries.  This makes the status of code contributed by European
developers unclear.

Those legal issues are not specific to Gentoo.  They have resulted
in a large number of projects creating various kinds of Contributor
License Agreements [#CLA]_.  One of the most interesting variants is
Fiduciary Licence Agreement (FLA) [#FLA]_.  Technically, the old
copyright forms could be replaced by such a document.  However, all
contributors would be required to sign it before contributing
any copyrightable work.  This is quite inconvenient, and other open
source projects have already suffered loss of contributors for this
precise reason (for one, I don't contribute to Google projects anymore).

The current copyright draft [#NEW-POLICY-DRAFT]_ aims to provide users
the choice between two models: retaining copyright, or sublicensing
to Gentoo Foundation via FLA.  While this wouldn't give us the full
coverage of copyright, it should provide a reasonable compromise between
the benefits of copyright ownership and contributor's convenience
and need for attribution.


References
==========
.. [#FIRST-COMMIT] [gentoo-x86] /header.txt; r1.1
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/header.txt?revision=1.1&view=markup)

.. [#ROBBINS-20030821] Daniel Robbins, Re: [gentoo-dev] Why should
   copyright assignment be a requirement?
   (https://archives.gentoo.org/gentoo-dev/message/60630a3e1b5ba40c49fa65daadd45fbd)

.. [#PORTNOY] Jon Portnoy, Re: [gentoo-dev] ebuild copyright attribution?
   (https://archives.gentoo.org/gentoo-dev/message/6754792cbe9763d249a0c4ee3d3f0602)

.. [#GPLV2-COMMIT] [gentoo-x86] /x11-misc/wmakerconf/wmakerconf-2.8.1.ebuild r1.1
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/x11-misc/wmakerconf/wmakerconf-2.8.1.ebuild?hideattic=0&revision=1.1&view=markup)

.. [#ROBBINS-20020207] Daniel Robbins, Re: [gentoo-dev] Ebuild info:
   author, maintainer and copyrights
   (https://archives.gentoo.org/gentoo-dev/message/7a857384b8929cb930329eb59e27636a)

.. [#GPLV3-GUIDE] Brett Smith, A Quick Guide to GPLv3
   (https://www.gnu.org/licenses/quick-guide-gplv3.en.html)

.. [#COPY-FORM] [gentoo] /xml/htdocs/proj/en/devrel/assignment.txt r1.1
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/devrel/assignment.txt?hideattic=0&revision=1.1&view=markup)

.. [#ZYNOT] The Zynot Foundation (archived 2003-08-04)
   (http://web.archive.org/web/20030804132831/http://www.zynot.org:80/)

.. [#LETTER-TO-ZYNOT] Jeffrey D. Myers, letter regarding Zynot copyright
   violation
   (https://web.archive.org/web/20031030042426/http://dev.gentoo.org/~drobbins/letter-to-zynot.txt)

.. [#BUG-55572] Bug 55572 (tomk) - Retire: Tom Knight (tomk)
   (https://bugs.gentoo.org/55572#c7)

.. [#LIEBER-20040629] Kurt Lieber, [gentoo-trustees] copyright assignment doc
   (https://archives.gentoo.org/gentoo-trustees/message/a8fed0ebe05befb8463a1f4b09c4ed09)

.. [#WATERS-20040701] Deedra Waters, [gentoo-trustees] copyright forms and new devs
   (https://archives.gentoo.org/gentoo-trustees/message/d860d16f85dc6cea23077b0ff8b979c0)

.. [#200410-STATUS-UPDATE] Sven Vermeulen, [gentoo-nfp] Status Update
   of the Gentoo Foundation
   (https://archives.gentoo.org/gentoo-nfp/message/24adbb5301b339663963fa203da51cae)

.. [#COPY-FORM-FOUNDATION] [gentoo] /xml/htdocs/proj/en/devrel/copyright/assignment.txt r1.2
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/devrel/copyright/assignment.txt?hideattic=0&revision=1.2&view=markup)

.. [#COPY-FORM-RM] [gentoo] /xml/htdocs/proj/en/devrel/copyright/assignment.txt
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/devrel/copyright/assignment.txt?view=log&hideattic=0)

.. [#BUG-140286] Bug 140286 - out of date copyright information
   (https://bugs.gentoo.org/140286#c2)

.. [#FOUNDATION-AOI] Foundation: Articles of Incorporation
   (https://wiki.gentoo.org/wiki/Foundation:Articles_of_Incorporation)

.. [#FOUNDATION-COPY-COMMIT] [gentoo-x86] /app-accessibility/at-poke/at-poke-0.2.1.ebuild r1.3
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/app-accessibility/at-poke/at-poke-0.2.1.ebuild?hideattic=0&revision=1.3&view=markup)

.. [#NEW-POLICY-DRAFT] Richard Freeman, Alice Ferrazzi, Ulrich Müller,
   Robin H. Johnson: Copyright Policy [draft]
   (https://github.com/ulm/copyrightpolicy/blob/master/glep-copyrightpolicy.rst)

.. [#REPOMAN-COPY] [gentoo-src] /portage/bin/repoman r1.32
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-src/portage/bin/repoman?revision=1.32&view=markup)

.. [#ROBBINS-20020207-2] Daniel Robbins, Re: [gentoo-dev] Ebuild info:
   author, maintainer and copyrights
   (https://archives.gentoo.org/gentoo-dev/message/8025ad7c83e29d0db66044b47b47bbaf)

.. [#CLA] Wikipedia: Contributor License Agreement # Users
   (https://en.wikipedia.org/wiki/Contributor_License_Agreement#Users)

.. [#FLA] FSFE: Fiduciary Licence Agreement (FLA)
   (https://fsfe.org/activities/ftf/fla.en.html)
