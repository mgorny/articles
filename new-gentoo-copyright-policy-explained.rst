=============================================
New Gentoo copyright policy explained (draft)
=============================================
:Author: Michał Górny
:Date: 2018-09-17
:Version: 1.0
:Copyright: http://creativecommons.org/licenses/by/3.0/


.. WARNING::
   This is a draft article in process of being reviewed.  Please take
   its statements with caution.


.. contents::


Preamble
========
On 2018-09-15 meeting, the Trustees have given the final stamp
of approval to the new Gentoo copyright policy outlined in GLEP 76
[#GLEP76]_.  This policy is the result of work that has been slowly
progressing since 2005, and that has taken considerable speed by the end
of 2017.  It is a major step forward from the status quo that has been
used since the forming of Gentoo Foundation, and that mostly has been
inherited from earlier Gentoo Technologies.

The policy aims to cover all copyright-related aspects, bringing Gentoo
in line with the practices used in many other large open source
projects.  Most notably, it introduces a concept of Gentoo Certificate
of Origin that requires all contributors to confirm that they are
entitled to submit their contributions to Gentoo, and corrects
the copyright attribution policy to be viable under more jurisdictions.

This article aims to shortly reiterate over the most important points
in the new copyright policy, and provide a detailed guide on following
it in Q&A form.


Why do we need a new policy?
============================
Gentoo never really had much of a copyright policy.  According to Daniel
Robbins:

  What we are doing now began way back when we figured out that slapping
  a "Copyright 2000 Gentoo Technologies, Inc." allowed us to comply with
  the GPL and get back to coding.  [...]  [#ROBBINS-20030821]_

The flaws of this concept were already noticed in late 2003.  Having
a potential copyright pursuit in view, Gentoo Technologies created
a formal copyright policy and started collecting signed copyright
assignment forms.  However, the effort did not breed much success and it
was abandoned half a year later by the newly-appointed Trustees
of Gentoo Foundation.

At the same time, discussion about the flaws of copyright efforts so far
as well as the first debate on forming a new copyright policy started.
This debate has been restarted multiple times over the years with little
progress.  Nevertheless, a number of arguments kept reoccurring.
To list only a few major issues:

1. Assigning copyright to Gentoo Foundation needs to be accompanied
   by a signed copyright form.  Without a document confirming it,
   the Foundation's copyright claim is weak.

2. Laws of multiple countries (e.g. many of the European countries) do
   not permit transferring all copyrights.  It is doubtful whether
   assignments made by Gentoo developers residing in those countries
   are meaningful.

3. Not all contributors agree to transferring copyright to Gentoo
   Foundation.  Forcing Gentoo Foundation copyright requires Gentoo
   to reject some contributions.  In some cases there's a real risk
   of contributors violating a copyright of a third party through
   replacing copyright header in order to get their contribution
   accepted.

Besides, there was really no single consistent policy.  A few projects
followed the same rules as the Gentoo ebuild repository.  Some others
had their own policies, some did not have any defined policy.

A more complete view of the history of copyright in Gentoo, along with
detailed evidence, can be found in my earlier article ‘A short history
of Gentoo copyright’ [#GENTOO-COPYRIGHT-HISTORY]_.


Whom does the new policy apply to?
==================================
The first important thing about the new policy is that it *uniformly
applies to all Gentoo projects*.  More specifically, all official Gentoo
projects are required to follow it, as well as all projects hosted
on Gentoo Infrastructure.

Enforcing a single policy has two major advantages.  Firstly, it
protects Gentoo by ensuring that all our projects and the projects we're
hosting conform to a policy that is known to be reasonably good.
Secondly, it eases things for our users and contributors by eliminating
the need to research disjoint policies used by different projects.


**Will the new policy apply to existing projects?**
  Yes, we will require all existing projects to eventually start
  complying with the new policy.  We obviously won't be able to force
  compliance retroactively, or force all projects to immediately start
  using it.  However, after the transition period we will require all
  new commits (or other form of project updates) to conform with
  the policy.

**Will old non-compliant projects be removed?**
  There are currently no plans on removing old projects.  However, we
  might be required to remove a project if we receive a justified
  request e.g. because of copyright violation.

**Will I be able to use my own copyright policy?**
  At the moment, no such provisions are planned.  If you find our policy
  wrong or problematic, please open a discussion on how to improve it
  to cover your use case.

**Will unofficial Gentoo projects be required to follow the policy?**
  Only if they intend to be hosted on Gentoo infrastructure.  However,
  we strongly recommend all unofficial Gentoo projects to use
  the policy.

**Project X is not following the policy.  What should I do?**
  Please contact the project developers, possibly by reporting a bug.
  If the developers deliberately choose to violate the policy and reject
  your report, please escalate the issue to the Council.


Licensing of Gentoo projects
============================
The first part of the new policy specifies the licenses allowed for use
in Gentoo projects.  The policy specifically provides for:

  a) The GNU General Public License, version 2 or later (GPL-2+)
     [#GPL-2]_.

  b) The Creative Commons Attribution-ShareAlike 4.0 License
     (CC-BY-SA-4.0, only for documentation) [#CC-BY-SA-4.0]_.
     Existing projects may also stay with CC-BY-SA-3.0 [#CC-BY-SA-3.0]_.

  c) A license approved as GPL compatible by the Free Software
     Foundation [#GPL-COMPAT]_.

The license restrictions are mostly an extension of the Gentoo Social
Contract [#SOCIAL-CONTRACT]_.  The choice of allowed licenses meant to
cover a wide set of free software (documentation, …) licenses that our
official and unofficial projects may want to use, while on the other
hand limiting the ‘default’ set to licenses compatible with the GPL.

We've deliberately chosen to refer to FSF license list to avoid having
to maintain our own list.

Please make sure not to accidentally violate copyright law while making
your project adhere to the new policy.  For information on baseline
problems such as common license misconceptions, combining licenses
and relicensing software, you can read my ‘copyright 101’ [#COPY-101]_.


**What about licenses approved by Open Software Initiative?**
  Many of the OSI-approved licenses are already covered by the allowed
  license statement above.  If you would like to use one that isn't,
  please follow the procedure for other open source licenses below.

**What about other open source licenses?**
  If you would like to use an open source license that is not explicitly
  permitted by this policy, please file a request to the Gentoo
  Foundation.  If the request is justified and the license in question
  does not violate the Gentoo Social Contract, the Trustees will grant
  you the possibility of using it.

**What about non-free licenses?**
  By the Social Contract, Gentoo is not permitted to release any of its
  projects under non-free licenses.  If you e.g. need to fork a non-free
  software to work on it, please make it clear that it is not
  an official Gentoo project and preferably host it outside Gentoo
  infrastructure.  If you insist on using Gentoo infrastructure
  to hosting it, please request explicit license exception.

**What about public domain?**
  The concept of public domain is quite diverse across different
  jurisdictions, and it is not necessarily clear that you actually can
  release software into public domain.  Please consider using CC0
  license instead (which is FSF-approved) [#CC0]_.

**Will Gentoo no longer provide ebuilds for non-free software?**
  Gentoo will continue to provide ebuilds for non-free software.  This
  policy only affects licenses of the code placed *directly* within
  Gentoo projects.  It does not affect licenses used by software
  packaged for Gentoo.

**Will existing projects need to be relicensed?**
  If any Gentoo projects use free software licenses that aren't
  explicitly permitted by the policy, they will have to request
  an explicit license exception from the Trustees.  If you choose
  to relicense your project instead, *please make sure to obtain
  permission from all copyright holders.*

**What about projects without a license?**
  Projects without explicit license are generally regarded
  as all-rights-reserved, unless they truly contain no copyrightable
  material.  As such, they do not conform to this policy and will
  eventually have to be licensed explicitly or disabled.  However, once
  again, please note that *you need to obtain permission from copyright
  holders before relicensing the repository.*

**Can I add non-GPL ebuilds to the Gentoo repository now?**
  No, the Gentoo ebuild repository still requires GPL-2 as a tree
  policy.


Certificate of origin approval
==============================
The next part of the policy introduces a Gentoo Certificate of Origin
alike the document used in Linux Kernel.  The goal is that all
committers acknowledge that their work can be legally integrated
into the project.

::

    By making a contribution to this project, I certify that:

    1. The contribution was created in whole or in part by me, and I
       have the right to submit it under the free software license
       indicated in the file; or

    2. The contribution is based upon previous work that, to the best
       of my knowledge, is covered under an appropriate free software
       license, and I have the right under that license to submit that
       work with modifications, whether created in whole or in part by
       me, under the same free software license (unless I am permitted
       to submit under a different license), as indicated in the file;
       or

    3. The contribution is a license text (or a file of similar nature),
       and verbatim distribution is allowed; or

    4. The contribution was provided directly to me by some other
       person who certified 1., 2., 3., or 4., and I have not modified
       it.

    I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the free software license(s) involved.

In order to commit to any Gentoo project, you need to acknowledge
the GCO by adding a *Signed-off-by* line to the footer of your commit
(``git commit -s`` does that for you).  Since you're effectively making
a legal statement, it is important that this line contains your real
name and working e-mail address.

The curious thing about the GCO is that it's recursive.  If somebody
submits his work to you, he needs to acknowledge the GCO, and then you
can acknowledge it via option (4).  Each GCO approval in this pipeline
creates an additional *Signed-off-by* line, making it possible to trace
the contribution to its root.

The policy additionally permits using the original Linux DCO 1.1
[#DCO-1.1]_ when contributors do not wish to use our GCO.  This needs
to be explicitly noted via appending ``(DCO-1.1)``
to the *Signed-off-by* line.  Please note that you aren't legally
allowed to commit licenses this way!


**What should I do if I can't certify neither of those points?**
  In that case, the contribution in question can not be merged
  into the appropriate Gentoo project.  You may need to start
  from scratch.

**How should contributions from third parties be dealt with?**
  Any copyrightable contribution (i.e. extending beyond trivial changes
  such as typo fixes) needs GCO being acknowledged by its author.
  Preferably, he'd do it by inserting *Signed-off-by* into his patch,
  or otherwise permitting you to do that.  Afterwards, you acknowledge
  GCO via point (4), and/or (2) if you have modified it, and add your
  own *Signed-off-by* below his.

**Can I use patches/code that I found online?**
  Only if you are certain that you are entitled to use it, according
  to point (2).  In other words, the code should clearly indicate that
  it's covered by a compatible free software license.  If it does not,
  you need to find its author and request his GCO approval
  and afterwards use it according to point (4).

**Does ordering of Signed-off-by matter?**
  Yes, it does.  The *Signed-off-by* lines are naturally appended
  top-to-bottom.  Therefore, we assume that the last person listed
  verified the signoff of the person above him, etc.

**Do I have to use my real name?**
  Yes, using real legal name (i.e. the name you use in officially signed
  documents) is required.

**Do I have to use my primary e-mail address?**
  You need to use a working e-mail address that can be used to contact
  you.  It does not have to be your primary address.

**Will Gentoo verify my real name?**
  At the moment, there are no plans to request any evidence of your
  real name.  However, we reserve the right to reject a contribution
  when there is evidence that it was submitted under a pseudonym.

**Why does Gentoo need a custom Certificate of Origin?**
  The Linux Kernel DCO fails to account for license files.  Those files
  are naturally covered by a license prohibiting modification,
  and therefore could not have been committed via the DCO.  We have
  determined that it's cleaner to have a unified text covering this
  rather than expect people not to certify the DCO when committing
  licenses.

**My employer accounts for the Linux DCO only.  What can I do?**
  If your employer prohibits you from entering arbitrary legal
  agreements while contributing, you should preferably ask him to review
  our Certificate of Origin.  If there is no chance for that, you can
  use the Linux DCO option.  However, please note that you most likely
  will not be able to commit additional licenses this way.


Copyright ownership
===================
An important difference from the status quo is that the new policy does
not require you to assign the copyright to the Gentoo Foundation.
An option for FLA-style assignment might be added in the future
but in the most basic form, whoever owns the copyright to the changes
keeps it.

This is something some of our users were anticipating, and I think many
more will be appreciate, at least initially.  It will also make it
possible for people with different copyright agreements signed
to contribute to Gentoo (e.g. when your employer claims copyright on all
your work).

The policy provides two methods of attributing copyright in files:
complete and simplified.  The simplified method is recommended whenever
tracking the exact authorship of code could be a problem, e.g. due
to a large number of authors in ebuilds.

With the simplified method, the copyright line will usually look like::

    # Copyright START[-END] Gentoo Authors

With the complete method, it would be::

    # Copyright START[-END] LARGEST-OWNER [and others]

*START* indicates the earliest year that the listed owners claim
copyright to the file.  *END* indicates the latest.  *LARGEST-OWNER* is
the name of the person (or company) holding copyright to the most
of the file (this might be hard to determine), and the *‘and others’*
formula is used whenever there are more copyright holders (so that you
don't have to list them all).  Alternatively, the *‘Gentoo Authors’*
formula is used to represent all authors without listing anyone
explicitly.

With either method, you are still required to track authorship.  If you
are using a VCS, it is enough that the list of all authors (copyright
owners) can be obtained from its logs.  Otherwise, you should maintain
an ``AUTHORS`` file listing them.


**Can I continue attributing Gentoo Foundation?**
  This is not possible at the moment.  It might be allowed in the future
  under separate terms.  For time being, we recommend attributing
  ‘Gentoo Authors’ instead.

**What about Gentoo Foundation copyright on existing ebuilds?**
  Preferably convert it to ‘Gentoo Authors’ when you modify the file.

**When should the simplified/complete attribution be used?**
  The policy does not define limits on using either form.  Use whichever
  you find more suitable to your purpose.  We generally recommend
  simplified attribution whenever exact authorship tracking would
  be hard (e.g. due to a large number of authors).

**Can I replace complete copyright attribution with simplified?**
  Generally, yes, as long as the original copyright holder can
  be tracked down via VCS or AUTHORS file.  However, if somebody put
  an explicit copyright notice, it would be polite to ask him first.

**I have signed an exclusive copyright assignment.  Can I contribute?**
  Yes, you can.  If your employer or any other entity holds copyright
  on your contributions, just use its name in place of yours.

**What if I contribute only in my free time, independent of work?**
  I'm sorry but we can't answer that question.  If in doubt, please ask
  your employer.

**When can I remove the ‘and others’ formula?**
  You can remove it if you are *really, really* sure that you are
  the only copyright holder at the moment.  That is, that the existing
  ebuild code does not include and is not based on contributions made
  by other people.

**Do I ever change START date?**
  Rarely.  Technically, you could change it if old contributions are
  no longer relevant to the current file.

**Where should I report misattributed copyright?**
  If you believe that the copyright in some file is not attributed
  correctly, please file a bug to the project.  If the maintainer does
  not reply or disagrees with you, you can escalate the issue to
  the Trustees, providing evidence to your claims.

**Can multiple copyright holders be listed explicitly?**
  The policy technically allows listing multiple copyright holders
  but it is discouraged.


References
==========
.. [#GLEP76] GLEP 76: Copyright Policy
   (https://www.gentoo.org/glep/glep-0076.html)

.. [#ROBBINS-20030821] Daniel Robbins, Re: [gentoo-dev] Why should
   copyright assignment be a requirement?
   (https://archives.gentoo.org/gentoo-dev/message/60630a3e1b5ba40c49fa65daadd45fbd)

.. [#GENTOO-COPYRIGHT-HISTORY] Michał Górny, A short history of Gentoo
   copyright
   (https://dev.gentoo.org/~mgorny/articles/a-short-history-of-gentoo-copyright.html)

.. [#GPL-2] GNU General Public License, version 2 or later
   (http://www.gnu.org/licenses/gpl-2.0.html)

.. [#CC-BY-SA-3.0] Creative Commons Attribution-ShareAlike 3.0
   Unported License
   (http://creativecommons.org/licenses/by-sa/3.0/)

.. [#CC-BY-SA-4.0] Creative Commons Attribution-ShareAlike 4.0
   International License
   (http://creativecommons.org/licenses/by-sa/4.0/)

.. [#GPL-COMPAT] GPL-compatible free software licenses
   (https://www.gnu.org/licenses/license-list.en.html#GPLCompatibleLicenses)

.. [#SOCIAL-CONTRACT] Gentoo Social Contract
   (https://www.gentoo.org/get-started/philosophy/social-contract.html)

.. [#COPY-101] Michał Górny, Copyright 101 for Gentoo contributors
   (https://blogs.gentoo.org/mgorny/2018/05/08/copyright-101-for-gentoo-contributors/)

.. [#CC0] Creative Commons, CC0
   (https://creativecommons.org/share-your-work/public-domain/cc0/)

.. [#DCO-1.1] Developer's Certificate of Origin 1.1
   (https://developercertificate.org/)
