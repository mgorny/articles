==============================
The story of Gentoo management
==============================
:Author: Michał Górny
:Date: 2018-05-25
:Version: 1.0
:Copyright: https://creativecommons.org/licenses/by/3.0/


.. contents::


Preamble
========
I have recently made a tabular summary of (probably) all Council members
and Trustees in the history of Gentoo [#MANAGEMENT-TABLE]_.  I think
that this table provides a very succinct way of expressing the changes
within management of Gentoo.  While it can't express the complete
history of Gentoo, it can serve as a useful tool of reference.

What questions can it answer?  For example, it provides an easy way to
see how many terms individuals have served, or how long Trustee terms
were.  You can clearly see who served both on the Council
and on the Board and when those two bodies had common members.  Most
notably, it collects a fair amount of hard-to-find data in a single
table.

Can you trust it?  I've put an effort to make the developer lists
correct but given the bad quality of data (see below), I can't guarantee
complete correctness.  The Trustee term dates are approximate at best,
and oriented around elections rather than actual term (which is hard
to find).  Finally, I've merged a few short-time changes such as empty
seats between resignation and appointing a replacement, as expressing
them one by one made little sense and would cause the tables to grow
even longer.

This article aims to be the text counterpart to the table.  I would like
to tell the history of the presented management bodies, explain
the sources that I've used to get the data and the problems that I've
found while working on it.

As you could suspect, the further back I had to go, the less good data
I was able to find.  The problems included the limited scope of our
archives and some apparent secrecy of decision-making processes
at the early time (judging by some cross-posts, the traffic on -core
mailing list was significant, and it was not archived before late
2004).  Both due to lack of data, and due to specific interest
in developer self-government, this article starts in mid-2003.


Gentoo top-level management
===========================

Early managers
--------------
The first known well-defined form of Gentoo management was the top-level
management structure (apparently later called *metastructure*) defined
in GLEP 4.  The structure is described as:

  [...]  This management structure will consist of the chief architect
  and a group of developers that will be given the title of "Top-level
  managers." Top-level managers will be accountable for the projects
  they manage, and be responsible for communicating the status of their
  projects to the rest of the top-level managers and chief architect,
  among other things detailed later in this document.

  All the top-level projects in the Gentoo project will be clearly
  defined, including with goals, sub-projects, members, roadmap and
  schedules.  [...]  [#GLEP4]_

So apparently a number of top-level projects is defined, and managers
(leads) of those projects form the management team along with the chief
architect of Daniel Robbins.  GLEP 4 also includes the list of initial
managers, top-level projects and a lot of bureaucracy for them
to follow.

According to the dates inside the GLEP, it was posted by the end of June
2003, and the implementation work started soon after.  The first project
list was posted on the site on 2003-07-19 [#PROJECTS-STATIC]_; it has
been later renamed (without changes) and can still be found
in the archival version of our website [#PROJECTS-ARCHIVE]_.
It introduces a few differences from the GLEP: gentoo-linux project is
gone, and three new projects appear: metastructure, gentoo-base
and documentation.  It also features a group of orphan projects that
apparently are not included in the top-level management.

The original projects page does not clearly distinguish managers
from regular project members.  In some cases, the top-level projects
list only one member, or the first member is listed out of order (with
other members being sorted lexically).  By comparing the list obtained
from those apparent leads with GLEP 4 on one hand, and with future
manager lists on the other hand, we can arrange a working hypothesis
on who managed most of the projects.  According to this hypothesis,
the main difference between GLEP and the site would be reducing most
of the projects to one manager, with Daniel Robbins disappearing from
the explicit listings.

The next data point is 2003-09-22 when the previous static listing was
replaced by an index dynamically including different project pages
in Gentoo (that was used until 2013) [#PROJECTS-DYNAMIC]_.  Initially,
this file included an explicit list of managers and only three projects
(including a new Desktop TLP).  According to commit messages, all
missing TLPs were added on 2003-09-30 [#PROJECTS-ALLTLP]_, forming
a list equal to the one from previous site, plus the new Desktop
project.  A commit later, on 2003-10-09 the last manager was added
to the list [#PROJECTS-ALLMANAGERS]_.

At this point, I think that we can form a first clear list of top-level
managers in Gentoo.  Some of the projects already have a project page
with complete member list.  Others are only included on the list along
with their leads.  By combining the managers and leads listed
in the top-level projects, we can account for all managers explicitly
listed on the project list.  However, we do not have enough data to
clearly assign them to specific projects yet.


How were managers selected?
---------------------------
One of the key issues on which my research was focused was determining
how were various management bodies selected.  After all, if managers are
to be considered Gentoo's body of self-government, it would be crucial
for Gentoo developers to have an actual say in selecting the managers.

The metastructure proposal was written by Daniel Robbins, the chief
architect of Gentoo.  While this would effectively put him as the one
choosing initial management team, there is evidence to suggest that he
based the list on existing responsibilities within Gentoo.  Quoting
his reply to feedback on the metastructure proposal:

  [...]  Meaning that existing roles and responsibilities of developers
  within the Gentoo Linux project will be fully respected and reflected
  in the organization as this plan is implemented.  [#ROBBINS-20030625]_

For example, you can see that the manager of the Hardened project used
to be its lead prior to GLEP 4 [#HARDENED]_.  As a matter of historical
curiosity, the Hardened project seems to be the first Gentoo project to
have a site in the GuideXML system.

The procedure for manager changes afterwards is less clear.  It was not
specified in GLEP 4.  A mail from Daniel Robbins, posted on 2003-07-15
states:

  Currently, new managers are elected by unanimous vote of the existing
  managers.  [...]  [#ROBBINS-20030715]_

When the Desktop TLP project was formed, the managers apparently had
a problem selecting the lead.  The problem was pointed out during
the 2003-12-15 manager meeting:

  Paul de Vrieze (pauldv) presented the nominees for the desktop lead
  position (foser, liquidx, spider, spyderous, and tseng), and it
  immediately became clear that the new procedures for electing
  a manager were far from well-defined.

  [...]  Dennis M.D. Ljungmark (Spider) from the desktop group pointed
  out that the desktop group had not really participated
  in the selection process, noting that "the whole process seem[ed]
  opaque and closed", a conclusion that apparently rendered, for them,
  the nomination process itself fairly pointless.

  That revelation pretty much shut down any actual discussion
  of the vote itself, as the discussion then focused on how to construct
  a fair, serviceable top-level manager selection procedure.  [...]
  [#MANAGERS-20031215]_

The 2004-05-17 Gentoo Weekly Newsletter indicates a change
in the selection method:

  Another Gentoo Managers' Meeting was held today on May 17th. The first
  items on the agenda were votes on requiring a supermajority
  of managers (66%) to confirm new managers, and on confirming John
  Davis as the lead for Release Engineering. The supermajority
  requirement was ratified, and subsequently John was confirmed
  as the the Release Engineering lead.  [#GWN-20040517]_

The model of GLEP 4 is hard to judge.  On one hand, it certainly
ratified delegating some of the decisional power to the developers.
On the other hand, the manager selection was always limited
to the existing managers and the manager terms were unlimited.
As a result, distribution of power still depended on the few people
holding it.  John Davis has pointed out those problems in his mail dated
2003-07-15  [#DAVIS-20030715]_.  It does not seem that his calls were
answered at the time.


The rise and fall of Gentoo Managers
------------------------------------
The early period of Gentoo Managers is marked by high activity.  GLEP 4
required status reports twice a week and weekly IRC meetings.  Sadly,
a lot of the related data is lost to Gentoo developers since it took
place on gentoo-managers mailing list.  While we seem to possess
the complete archives of it, we can't publish them since there is
no indication that the mailing list was intended to be published
as a whole.  Quoting another of Daniel Robbins' replies from 2003-06-25:

  The gentoo-managers list is intended for "meetings."  I fully support
  having the weekly manager status updates posted publicly on project
  pages as part of our accountability to our users.  I think
  the meetings themselves should be private though.  But each project's
  and subproject's weekly status should be public information. 

On the plus side, it seems that the manager meetings were public
after all and the logs of all meetings between 2003-11-03 and 2004-07-19
are available [#MANAGER-MEETING-LOGS]_.  Additionally, meetings up
to 2004-03-08 include (GuideXML) summaries.  Besides that, some
of the decisions are to be found in the Gentoo Weekly Newsletter
[#GWN]_.

Did Managers have real deciding power?  It appears that they did.
Quoting Paul de Vrieze's mail from 2003-11-19:

  Key decisions are made by the management team.  A formal voting system
  is being developed, but currently we work with consensus vote.  Note
  that this is consensus of the management team.  In this Daniel
  [Robbins] has some extra edge as the project leader although it is not
  formal.  [#DE-VRIEZE-20031119]_

The first major scratch occurred around 2004-04-26.  This day, Daniel
Robbins announced his resignation from development roles
[#ROBBINS-RESIGNATION]_.  No Chief Architect was appointed
in replacement.  GLEP 4 was still in force, although the discipline
seemed to fade away.  Managers list traffic decreased, Manager meeting
logs stopped being published.  Once Gentoo Foundation was formed, many
of the managers started doubling as Trustees, making it harder to
exactly determine the role of Managers in the following year.

The first end point on the timeline of Managers is 2005-06-14.  This
day, the results of vote for the new metastructure were announced
[#METASTRUCTURE-VOTE-RESULTS]_.  What was later codified as GLEP 39
has been approved [#GLEP39]_.  Managers were at their last.

The first Council election results were published on 2005-09-01
[#COUNCIL-RESULTS-1]_.  The first Council met at 2005-09-15
[#COUNCIL-MEETING-1]_.  A few days later, the list of managers was
removed from the site [#MANAGERS-REMOVAL]_.


Putting it to the table
-----------------------
Fitting Managers into the management table was not an easy task.  But
why do it in the first place?  I wanted to include them because they
were predecessors to the Council.  I think the evidence to that is clear
— their powers were ratified by GLEP 4 metastructure, and the Council
was formed through a metastructure proposal replacing it.  In this
context, it seemed really interesting to compare the first elected
Council with the final team of Managers.

But who were on the final team?  This is really hard to answer.  When
originally researching managers, I had my share of doubt whether GLEP 4
was actually followed to the letter and new TLP leads were becoming
managers.  While we have found evidence to support that, it is unclear
whether it was still taking place during the last months of Manager
activity — whether the new TLP leads were confirmed by the Managers
and accordingly added to the mailing list.

Let's look at the CVS logs of various project pages in reverse
chronological order.  We see that Mike Frysinger became co-lead of base
system in August 2005; a month earlier Brandon Hale was removed
from desktop (apparently inactive since March [#TSENG-RETIREMENT]_)
and Sven Wegener created a new page for QA project listing himself
as the lead.  All of this happened already past the new metastructure
vote, and past last activity of gentoo-managers list.  Should we
consider either of them Managers then?

Let's look further.  May 2005 brings Jon Portnoy (temporarily) stepping
down from Developer Relations top-level management and a complete
leadership change in Portage project — three new leads.  Apparently they
weren't added to the -managers list but posted the project status
by proxy.  I think we can consider this the most relevant point for
the final team — although it is unclear if all TLP leads were actually
participating in the management, or considering themselves Managers.

Once we know whom to put, the next problem is how to put the data
in the table.  Originally I wanted to place Managers just below
the Council, to emphasize on the succession.  However, this met two
problems.  Firstly, it would put Managers in 2004/05 term (respective to
the Trustee term) which would be quite imprecise given that Managers
were not really running in terms.  Secondly, the count of 20 apparent
Managers in May 2005 would be a hard fit, compared to 7 Council members.
Therefore, I've decided to place them in a separate table.

Finally, I was wondering whether I should assign them to their
respective projects instead of using a flat list.  Both approaches have
their advantages.  A flat list puts more focus on the management team
and its members.  The project assignment indicates which projects were
considered top-level, at the cost of duplicating some of the managers.
For those reasons, I've included both variants.


Conclusion
----------
The GLEP 4 metastructure was probably the first official management
structure of Gentoo.  It structured the distribution in a hierarchy,
with Chief Architect and top-level project managers on top,
and subprojects below them.  It created a certain vertical model, with
subprojects answering to their parent projects, and parent projects
representing their subprojects.

Was it a revolution?  I wouldn't consider it so.  It is apparent that
some developers already had some degree of decisional power
and influence in Gentoo.  Daniel Robbins admitted that the structure was
meant to reflect the developer roles at the time [#ROBBINS-20030625]_.
However, the choice of top-level projects may have reduced the influence
of some of the developers.  For example, in reply to Joshua Brindle
Daniel Robbins admits that his project has been moved under gentoo-alt
umbrella [#ROBBINS-20030625-2]_.

Was it a democracy?  Certainly it was a step towards it, though it
wasn't one yet.  The power started being distributed but the access to
it was limited to a closed group of Managers.  A few developers have
managed to join the group but it certainly wasn't open.  In the end,
only people contributing to specific areas (top-level projects) could
have become Managers, upon approval from other Managers.

Was it a good model?  Hard to tell.  Certainly it worked for some time
but it seems that it eventually started to decline.  That might have
been related to Daniel Robbins leaving, or to Managers focusing on their
other roles as Trustees.  That might simply have been caused by people
having less time to work on Gentoo.  In any case, it eventually stopped
fitting the needs of Gentoo at the time and was replaced.


Gentoo Foundation
=================

The beginnings of the Foundation
--------------------------------
Originally, Gentoo has been backed by a commercial company Gentoo
Technologies, owned and run by Daniel Robbins.  Apparently, not all
developers agreed with this model.

The earliest mention of a Gentoo not-for-profit I was able to find was
in Daniel Robbins' mail dated 2003-06-25, in reply to the GLEP 4
metastructure proposal:

  On Tue, Jun 24, 2003 at 09:15:00PM -0500, Joshua Brindle wrote:

    [...]

    2) I didn't see not-for-profit mentioned, don't you think this is
    essential to the success of gentoo?

  Yes, I think it is. Having me move out of the day-to-day management
  efforts will allow me to focus efforts on getting the not-for-profit
  started.  Right now I am simply too overwhelmed with work.
  [#ROBBINS-20030625-2]_

The mails around the time indicate that the non-profit status was
discussed and agreed on for some time already.  However, it did not
seem to be moving forward as some of the developers desired.
The for-profit endeavors made by Daniel Robbins have apparently caused
it to be forked into Zynot  [#ZYNOT-REASONS-FOR-FORKING]_.

The work on actually forming the non-for-profit seems to have started
in April 2004.  The first complete proposal is dated 2004-04-16:

  Gentoo Foundation, Inc. proposal

  The purpose of this foundation is to hold the intellectual property
  of the Gentoo free software project.  It will have a board of
  trustees.  This not-for-profit will be an open membership trade
  association. 

  Trade associations (unlike charities) can be more restrictive in their
  requirements for membership.  Membership will be limited to Gentoo
  developers.  The criteria for being a Gentoo developer will be
  determined by the board of trustees.  There will be no membership
  dues.

  There will be an initial board of trustees appointed, which will be
  selected to meet my commitments to existing managers and developers.
  This initial board of trustees will serve for one year from the
  establishment of the Gentoo Foundation, after which point the board
  will be elected by the members (Gentoo developers.)  After that,
  regular elections will be held (election cycle TBD) to determine board
  members.

  The Gentoo Store will pay for the establishment of this
  not-for-profit.  The Gentoo Store will also pay for the Gentoo
  Foundation's application for 501(c)(6) federal trade association
  status (~$5000 or so?)

  Gentoo Technologies, Inc. will transfer the copyrights and trademarks
  to the Gentoo Foundation.  In exchange, the Gentoo Foundation will
  grant Daniel Robbins & Gentoo Technologies, Inc. perpetual,
  non-exclusive, royalty-free use of the "Gentoo" trademark and "G"
  logo.  This will allow me to continue to run the Gentoo Store if I
  want.

  I will be a member of the initial board of trustees, to give
  legitimacy to the Gentoo Foundation and also show my commitment
  to the future success of this entity.  [#ROBBINS-20040416]_

Later on, Daniel Robbins resigned from this role on the initial Board.
The Foundation has been established on 2004-05-28.  This date, along
with the original appointed Board of Trustees can be found
in the Articles of Incorporation [#FOUNDATION-AOI]_.  At this point,
the 13 Trustees started working on solving various legal issues
regarding the new NFP.

The initial issues found in Sven Vermeulen's 2004-10-21 status update
include: registering Gentoo trademark and logo, setting up a bank
account, resolving copyright assignment issues and handling donations
[#VERMEULEN-20041021]_.  By December, the work on Bylaws has apparently
started [#GOODYEAR-20041201]_.

The first quarter of 2005 does not leave any trace of activity
on the Foundation mailing lists.  However, the first draft of Bylaws
is published [#BYLAWS-DRAFT]_.  The first topic of April are upcoming
Trustee elections:

  The Gentoo Foundation, Inc was incorporated on 28 May 2004.  According
  to the articles of incorporation, a new board of trustees needs to be
  elected within 13 months of its incorporation, which is coming up
  fast.  At the moment the only members of the foundation are the
  current trustees, and clearly that needs to change before we hold
  elections.  [#GOODYEAR-20050411]_

The Trustees agreed on inviting all Gentoo developers who have been
developers for at least one year [#GOODYEAR-20050416]_, discussed
the election procedures [#GOODYEAR-20050427]_ and give birth to
the voting software still used today [#GRIFFIS-20050428]_.

On 2005-05-21, Grant Goodyear confirmed receiving copyright
and trademark transfers from Gentoo Technologies [#GOODYEAR-20050521]_.
On 2005-09-14, he confirmed that Gentoo trademark has been registered to
the Foundation [#GOODYEAR-20050914]_.  The end of 2005 concludes
the early active period of the Foundation.


The dark years
--------------
The year 2006 brings little visible progress in the Foundation affairs.
This year's Trustee elections bring fewer nominees than the previous
ones.  Quoting Grant Goodyear's reply to Diego Pettenò:

  Diego 'Flameeyes' Pettenò wrote: [Tue Jul 04 2006, 01:34:02PM CDT]

    What happens if we don't get any nomination? I know it's early
    but... well usually there are some early shots, and in 4 days we had
    nothing.  This is strange to say the least.


  Well, it will make thinning out the list of trustees much simpler.

  [...]

  Assuming nobody complains too much, let's assume that the nominations
  and elections for trustees will coincide with those for council
  members.  I'm still suggesting that we limit the number of trustees to
  5, assuming that we will quickly replace any trustees who depart
  during his or her term.  As for Foundation membership, that's still a
  tricky issue, since the bylaws were never approved [...].
  [#GOODYEAR-20060706]_

The nominations bring only 5 nominees.  Therefore, they are accepted
as the new Board without a vote.  Seemant Kulleen announces it
on 2006-09-05 [#KULLEEN-20060905]_.  His mail immediately meets strong
response from Gentoo developers who disagree with skipping the vote.

On 2006-09-23 a new election is announced [#KULLEEN-20060923]_.  This
time, 7 developers are nominated and five of them are elected into
the Board (with small changes, compared to the earlier result)
[#GOODYEAR-20061021]_.  However, Seemant Kulleen resigns almost
immediately [#KULLEEN-20061023]_, and Stuart Herbert a month later
[#HERBERT-20061129]_.

There is no apparent Trustee activity during the first half of 2007.
The single mails sent by Gentoo developers to the mailing list remain
unanswered.  The upcoming 2007/2008 election does not bring even
sufficient number of candidates to fill all the slots
[#GIANELLONI-20070731]_.  At this point, Trustees seem to be working
towards SFC inception [#GOODYEAR-20070926]_.  There are no further news
until 2008.

The first massive peak of activity results from Daniel Robbins'
2008-01-11 blog post stating:

  Several days ago, the Gentoo community discovered the unfortunate news
  that the Gentoo Foundation's charter has been revoked for several
  weeks, which means that as of this moment the Gentoo Foundation no
  longer exists.
  
  [...]
  
  It also appears that all but two of the interim Foundation trustees
  have either resigned or are unreachable.  Grant Goodyear appears to be
  the only remaining trustee who actively does legal stuff, along with
  Chris Gianelloni who runs the Gentoo Store.  [#ROBBINS-20080111]_

The Grant Goodyear's update from 2008-01-18 provides more details:

  With help from Renat Lumpau (rl03), I spent some time this week
  talking to the Foundation's lawyers, collecting documents, and sifting
  through old e-mails.  As I posted on gentoo-nfp a couple of days ago,
  the state of New Mexico did, indeed, revoke the charter for the Gentoo
  Foundation, Inc. in October of 2007.  It's still not entirely clear
  why, since I mailed a check along with the (then) current and past-due
  annual reports to the state of NM way back in July.  Since the check
  never cleared, it seems a good guess that the paperwork went astray,
  but we won't know until Renat's request (and $5) are processed by NM
  and they get back to him.  [#GOODYEAR-20080119]_

He also confirms that all Trustees but himself and Paul de Vrieze have
resigned.

By the end of the month, nominations for new Trustee Board start.  This
time, a full Board of 5 Trustees is elected from the initial 8 nominees
[#VICETTO-20080229]_.  The new Trustees are much more successful.

By 2008-05-13, the Foundation is reinstated [#THOMSON-20080513]_.
On 2008-08-31, the first Bylaws are adopted [#BYLAWS-20080831]_
[#TRUSTEE-MEETING-200808]_.


Foundation then, Foundation yesterday
-------------------------------------
Since then, the Foundation has been operating with no major
interruptions.  The initial Bylaws already included the Trustee election
model still used today:

  Trustees shall normally hold office for a period not exceeding two
  electoral periods.  Trustees shall retire annually by rotation
  (and may be re-elected).  [...]  [#BYLAWS-20080831]_

They also included the restriction that:

  No individual shall serve as a Gentoo Foundation Trustee and Gentoo
  Council Member concurrently.  [#BYLAWS-20080831]_

Initially, only Gentoo developers were admitted to the Foundation.
However, the 2008-10 meeting already changed them to allow non-developer
members [#SUMMERS-20081117]_:

  Active Gentoo developers who are not members of the Foundation may
  apply for membership.  Any developer applying for membership
  in the Foundation will become a member of the Foundation immediately
  after the next Trustee meeting following the application unless
  an absolute majority of the trustees (currently 3 out of 5) oppose
  membership for the developer at this meeting.

  Applicants who are not Gentoo developers need to cite verifiable
  evidence of contributing to Gentoo or to the stated aims of the Gentoo
  Foundation Inc.  [#BYLAWS-20081116]_

The two following years again form a period of low activity, built
mostly around Trustee elections.  The silence is broken in January 2011
by a series of posts by William L. Thomson Jr., apparently summarized
in his final mail:

  Just making a quick list of the items/questions asked buried in a few
  posts in a previous thread. No need to reply till there are answers.
  This is just a list/summary of the items/questions to be answered once
  the internal audit has been completed.

  I am very appreciative and thankful that the trustees will be
  conducting an internal audit. I will patiently away the outcome,
  and answers to the following items/questions.

  1. State filings, with NMPRC and State Attorney General, bi-annual
     filings with NMPRC, and annual with State Attorney General
  2. Federal filings, annual tax return, form 990 (990-N or 990-EZ)
  3. Where is the money from the old bank account? When was it
     received/deposited into new account, and how much?
  4. What is the cause behind the $9k discrepancy in Q3 2010, and why
     was that not caught sooner, like in 2008 or 2009?
     [#THOMSON-20110328]_

In November 2011, Matthew Summers indicates that Foundation filings
are in order.

By the end of 2012, the topic of copyright is brought again, by Rich
Freeman [#FREEMAN-20121217]_.  This is not the first time Trustees
debate about copyright.  However, I think it is worth mentioning since
today's copyright work is based on the draft policy written by Rich.

Over the following years, the NFP mailing list traffic is low.
Recurring topics include copyright, logo usage and Social Contract,
financial reports and elections.


The recent months
-----------------
The Foundation activity starts to peak again in October 2016.  Matthew
Thode opens a discussion on changing the procedure for admission
of members to include a quiz [#THODE-20161013]_ which does not
eventually get implemented.  Neither does Robin H. Johnson's proposal
of admitting developers automatically [#JOHNSON-20161013]_.

On 2016-11-07, Alec Warner proposes merging Gentoo developers and staff
members into a single Gentoo member type [#WARNER-20161107]_.  This is
probably the first case in years when Trustees reach outside the direct
affairs of the Foundation.  In reply, Michael Palimaka points out that:

  That is no longer correct - "staffer" is a thing of the past.  These
  days, everyone is a developer whether they work on ebuilds or not.

  [...]

  While I applaud your efforts, the proposal seems to be based
  on an outdated picture of the community.  Additionally, given our
  current metastructure, it's not clear to me how this is even
  a Foundation issue.  [#PALIMAKA-20161109]_

On 2017-01-05, Matthew Thode proposes:

  [...]

  In order to solve this Gentoo needs to have a combined electorate,
  meaning those that would vote for Council would also vote for Trustees
  and visa-versa.  This would ensure that everyone’s needs are
  represented.  We should have a single combined governing body, let’s
  call it ‘The Board’.  This is so that conflicts between Council and
  Trustees (as they exist now) would have a straightforward resolution.
  This new ‘Board’ would be able to use the existing project
  metastructure to delegate roles to various groups (Comrel, Infra, etc
  would still exist, but under this new Board).  [#THODE-20170105]_

This post has started a major discussion on the role of Trustees
and Council that is still running today, as well of the purpose
of the Foundation.  It brought many replies, counter-proposals
and reiterations.  Since the process is far from finished, I will
not be getting into details.

The last fact to mention is that on 2017-06-19 Bylaws have been changed
again, to add the following requirement for Trustee candidates:

  Candidates standing for election must be active Gentoo Developers
  as of the record date (Effective 2017/07/04).  [#BYLAWS-20170619]_


Trustee elections
-----------------
While the first Board of Trustees has been explicitly appointed
by Daniel Robbins, the subsequent Boards are subject to elections.
The elections occur annually, and consist of nomination phase followed
by voting.  The votes are counted using Schulze method (which is one
of the Condorcet methods).

The electorate consists of all Foundation members.  Originally,
the membership was offered to all project members who were Gentoo
developers for at least one year.  By October 2008, this was changed to
allow all Gentoo developers (without the one year limit)
and non-developers who have contributed to Gentoo. According to
pre-2008 Bylaws and traditionally past that, Foundation membership
is terminated after not voting in two consecutive Trustee elections.

At first, all Foundation members could have been nominated.  The 2008
Bylaws change therefore implied opening Trustee nominations
to non-developer Foundation members.  This was changed again in 2017,
restricting Trustee candidates to active Gentoo developers.  Since 2008,
the Bylaws have explicitly forbidden a single individual from being
a Trustee and a Council member simultaneously.

The first election, held in 2005 resulted in 13 Trustees being elected.
7 of them were reelected from the original Board.  Upon the failure
of 2006 nominations, the Board was reduced to 5 Trustees, and their term
was ratified to the period of two elections.  Starting next year, half
of the Board was supposed to be rotated annually.  However, in reality
this did not start happening until 2009.  Afterwards, in a few cases
Trustees served for three years without reelection.

The popularity of Trustee elections fluctuated over the years.  As you
can see in the table, only some of the elections actually involved
voting.  Three of them (if we skip the one which was restarted) were
limited to the nominations phase, as they did not bring enough nominees
to dispute any of the seats.  The 2007 election brought so few
candidates that the Board did not change at all.

Besides annual elections, Trustee seats were subject to mid-term
resignations.  Those seats were filled by vote among the remaining
Trustees.  There were three kinds of candidates selected this way:

- highest-ranked candidates which did not make it to the Board during
  the previous election (*H* in the table),

- Foundation officers at the time (*O* in the table),

- Gentoo developers replying to open recruitment notices
  (*R* in the table).

Nevertheless, the Trustee Board historically had empty seats during
the 2006-2008 period, and the second half of the 2008/09 term.

The Trustee elections certainly had a democratic bit to them.  However,
they have a few weaknesses.  Those are:

1. Lacking a mechanism to veto a nominee, especially in case there
   are too few to hold an election.

2. Explicitly allowing arbitrary Trustee selection in case of vacant
   seat.

3. Giving Trustees arbitrary, direct control over their electorate.

The first argument was already raised during the first 2006 election
where all nominees were to be appointed Trustees without a vote due
to lack of candidates.  Ciaran McCreesh already tipped a solution back
then:

  A Debian-style "reopen nominations" option with a vote would make more
  sense...  [#MCCREESH-20060905]_

However, this proposal has never been considered seriously until I
proposed a more complete scheme that combined it with fallbacks that
accounted for the apparent necessities of the existing system
and provided an accurate timeline [#GORNY-20180418]_.  This proposal
has been accepted during May 2018 Trustee meeting and hopefully will
be used during the election following it.

The second point can't be solved that easily.  As some of the Trustees
point out, it is important to avoid long-term vacancies in the Board.
Therefore, Trustees will continue to appoint replacement for resigning
Trustees and hold power to appoint new Trustees in case of vacant seats.
On the plus side, those nominations are usually based on the previous
elections, so they end up being at least partially democratic.

The third point is specific to the simple structure of the Foundation.
At the moment, Trustees both approve (or reject) member applications,
and (via post-2008 Bylaws) determine the criteria for loss of interest
which influence membership terminations.


Finding the Trustees
--------------------
The previous section was focused on the theoretical side and examples
of Trustee elections.  Now it's time to say how I've managed to obtain
the results that can be seen in the table, what data sources did I use
and what that choice implies.

My first idea was to use the results provided by the Elections project
[#TRUSTEE-ELECTION-RESULTS]_.  However, this included only the results
for the three most recent elections, and full Board member lists only
for two of them.  By looking at the git repository [#ELECTION-GIT]_
or the historical CVS repository [#TRUSTEE-ELECTION-CVS]_, I could
obtain some more data but it would still not be sufficient to form
a full view.

My second idea was to use the Foundation website history.  However,
the effort of checking both the Wiki page history [#FOUNDATION-WIKI]_
and the historical GuideXML page history [#FOUNDATION-GUIDEXML]_ only
revealed more issues than it solved.  Not only was the data limited
to changes in the Board with little to no explanation but also some
of the delays and partial updates made the data confusing (e.g. Roy
Bamford has been listed as a Board member for 3 months after new Trustee
was added).

Nevertheless, the website history helped me a great deal as a secondary
information source which I consulted to confirm my results and establish
the approximate dates needed to find evidence of Board changes.

The third and final source of information were the Foundation mailing
lists.  Roy Bamford helped me greatly by suggesting to look into
the election announcement mails that indicated which Trustees were being
replaced by rotation.  At this point, the painstaking work started.
With each election representing a time point, the election results mail
established part of the Trustees past this point, while the election
announcement established part of the Trustees before this point who
finished their term.

This approach did not work reliably for all the terms though.  Mid-term
Trustee changes and Trustees serving three terms made the data
inconsistent, and confused me thoroughly.  However, with the help
of recollections of past Trustees combined with thorough search over
mailing list archives and comparison with website changes, I was
eventually able to establish the historical Board members and their
approximate terms.

Two periods posed the biggest problems to me: the 2006-2008 period,
and the 2014-2016 period.  In the first case, the limited data confused
me deeply.  I was able to find the 2006/07 election announcement,
the two resignations and the replacements.  However, I wasn't able to
find anything complete on the 2007/08 election.  Only after being
pointed to Grant Goodyear's 2008 status mail [#GOODYEAR-20080119]_,
I was able to establish the state of affairs by the end of 2007/08 term.
The period in between is still marked as ‘missing data’.

In the case of 2014-2016, the data I've collected simply did not fit.
I've requested help on the Foundation mailing list [#GORNY-20180517]_.
It turned out that my problem consisted of two successive cases
of three-year term combined with mid-term resignation.

Once I had a complete table of Trustees, the remaining task was to
establish how they were elected.  Based on the election mails, I was
able to distinguish full elections from nomination-only elections.
For mid-term replacements, the combination of meeting logs, election
mails, other mails and site logs led me to determine the most likely
reasons why a particular individual was selected.

Lastly, I would like to list one more source of information: meeting
logs.  While working on the Council member lists, I was able to use
their meeting logs to successfully verify the Council members throughout
the term.  Sadly, the Trustee logs were far from helpful.  Neither
the summaries (which rarely contain any useful information, and look
more like agenda), nor their metadata contained the list of attendees.
Even worse, the roll calls during the meetings were hardly readable
and did not really distinguish current Trustees from other attendees who
decided to ‘wave’ their hands along with them.


Conclusion
----------
The Gentoo Foundation has been formed in 2004 to provide
a not-for-profit entity to hold Gentoo copyright and trademarks, process
financials and handle all other legal aspects of Gentoo's existence.
Since then, it had its ups and downs.

They had to face a number of problems, starting with the periodic lack
of interest in Trustee positions and limited interest of third parties
in helping Gentoo.  They have reached to umbrella organizations more
than once but without success [#GOODYEAR-20070926]_.

They had to handle accounting, and sometimes deal with the problems left
over by their predecessors [#THOMSON-20110328]_.  They had to deal with
legal and IRS filings.  The former has already caused them trouble
[#GOODYEAR-20080119]_, the latter is still not completely solved
as of today [#JOINT-MEETING-20180120]_.

Historically, Trustees were handling issues directly related to
the legal and financial support of Gentoo.  This included such topics
as copyright issues (which are handled by a dedicated team today),
trademarks, donations and spendings.  However, recently Trustees
started showing interest in gaining influence over wider aspects
of Gentoo, with proposals going as far as to change the metastructure
[#THODE-20170105]_.

The Trustees have once again reached the peak on the timeline of their
activity.  Gentoo is at an interesting point, and it is hard to predict
what the future might bring.  Hopefully, all the most important problems
will be solved during this year, though unlikely before the next Trustee
elections.


Gentoo Council
==============

The metastructure debate
------------------------
The history of Gentoo Council begins in 2005.  It being with a poll
on changing the Gentoo metastructure as posted on 2005-06-08
[#METASTRUCTURE-VOTE]_.  Sadly, it seems that all the discussion leading
up to the vote was kept private.  However, we have been able to extract
the proposals put up for vote and Ulrich Müller has prepared a MediaWiki
conversion of their texts.  The proposals put up for vote were:

- The “FOSDEM” proposal, splitting projects into 7 groups, requiring
  quarterly project reports and manager meetings with one representative
  from each project [#METASTRUCTURE-FOSDEM]_.

- Thierry Carrez' “Alternative” proposal, also splitting projects
  into groups, with project-level meetings, group-level meetings
  of project leads, top-level meetings of project group secretaries
  and obligatory GLEPs for every global change
  [#METASTRUCTURE-ALTERNATIVE]_.

- Grant Goodyear's “Oldschool” proposal with non-grouped projects
  and a small Council (7-13 members) [#METASTRUCTURE-OLDSCHOOL]_.

- Grant Goodyear's “Oldschool” proposal with a large Council
  (e.g. ~10% of developers) [#METASTRUCTURE-OLDSCHOOL]_.

- Ciaran McCreesh's proposals combining both “Oldschool” proposals
  with “boot for being a slacker” [#METASTRUCTURE-OLDSCHOOL]_
  [#METASTRUCTURE-SLACKER-BOOT]_.

- Keeping the GLEP 4 metastructure [#GLEP4]_.

- Jason Stubb's “task force” proposal, combining the GLEP 4
  metastructure with a non-voting, top-level Task Force to “document
  and improve all structure, policies and procedures.”
  [#METASTRUCTURE-TASKFORCE]_

The vote results have been announced on 2005-06-14.  The “Oldschool”
proposal with “boot for being a slacker” and a small Council won
[#METASTRUCTURE-VOTE-RESULTS]_.  The final version of the proposal has
been codified into GLEP 39.  It describes the Council the following way:

  [...]

  B. Global issues will be decided by an elected Gentoo council.

     *  There will be a set number of council members.  (For the
        first election that number was set to 7 by acclamation.)
     *  Council members will be chosen by a general election of all
        devs once per year.
     *  The council must hold an open meeting at least once per month.
     *  Council decisions are by majority vote of those who show up (or
        their proxies).
     *  [...]
     *  Disciplinary actions may be appealed to the council.

  [#GLEP39]_

The first Council meeting was held on 2005-09-15 [#COUNCIL-MEETING-1]_.


Council elections
-----------------
The nominations for the first Council do not seem to have been public.
Apparently, the voting was open throughout August 2005, and the results
were published on 2005-09-01 [#COUNCIL-RESULTS-1]_.  However, in 2006
the nominations were already public [#COUNCIL-NOMINATIONS-2006]_.

The same model as for Trustee elections is used.  The elections occur
anually, and the Council term lasts a year.  The elections consist of
a nomination period, followed by vote.  Votes are counted using
Schulze method.

The electorate includes all active Gentoo developers, and only Gentoo
developers can serve on the Council.  New Gentoo developers are admitted
through Recruiters project.  The developer status can be terminated
by Undertakers project because of inactivity, or by Community Relations
project as a disciplinary action (historically, both those functions
were handled by Developer Relations).

When a Council seat was vacated throughout the term, the Council members
either have voted on accepting the next highest-ranked candidate from
the previous election, or ran an election for the missing seat.  GLEP 39
explicitly specifies procedures for removing inactive Council members
and reelecting the Council when a meeting does not reach the quorum
of 50% [#GLEP39]_.  Of these procedures, to this day the former has been
used exactly once (2009-12).

The _reopen_nominations option has been introduced during the second
elections of 2008 (for the missing seat):

  An important point in this election is the new *_reopen_nominations*
  candidate.  If this candidate ranks over all other candidates,
  the election will be reopened.  Any candidate that ranks below this
  candidate won't be taken into account if there's a need to replace any
  member of the council until the end of term.
  [#COUNCIL-NOMINATIONS-2008B]_

This finalized the Council election model as it is still used today.
Let's look at the same aspects that I've listed as problems in Trustee
elections:

1. Council elections *do* provide a way to veto a candidate.  If his
   name is voted below _reopen_nominations, he will not take the seat.

2. The Council members have been appointing members for mid-term vacant
   seats.  Only in two of the cases an election has been held.

3. The Council *does not* directly manage its electorate.  This is done
   by separate privileged team.  However, the Council *does* have
   indirect influence via serving as the appeal court for disciplinary
   actions.  There is also no limitation in Council members doubling
   as members of those teams.

The Council elections seem to be more democratic than Trustee elections
then.  The problem of vetoing a candidate has been solved there in 2008
already, and the wider structure reduced the Council's control
of electorate.


Important points in Council history
-----------------------------------
The history of Gentoo Council is not as interesting as the history
of Trustees.  During all the past years, the Council has been deciding
on technical and management aspects of Gentoo, reviewing GLEPs,
approving EAPIs, serving as a final court for technical disputes
and an appeal court for disciplinary actions.

Andreas K. Hüttel has compiled the past Council meeting summaries
into a single PDF document [#COUNCIL-DECISIONS]_.  Nevertheless, I'm
going to note a few events that had affected Gentoo long-term.

2006-01-12
  Council members are forbidden to act as proxies for other Council
  members [#COUNCIL-20060112]_.  GLEP 39 is updated appropriately
  [#GLEP39-20060209]_.

2007-03-15
  The first version of Gentoo Code of Conduct is approved
  [#COUNCIL-20070315]_.

2007-06-14
  gentoo-project mailing list is introduced, originally as unmoderated
  alternative to gentoo-dev [#COUNCIL-20070614]_.

2007-10-11
  GLEP 39 is amended to require a request-for-comments from every new
  project [#COUNCIL-20071011]_ [#GLEP39-20071012]_.

2008-09-11
  PMS/EAPI 0 is approved [#COUNCIL-20080911]_.

2010-08-09
  gentoo-council mailing list is disbanded, in favor of gentoo-project
  [#COUNCIL-20100809]_.

2014-01-19
  GLEP 39 is amended to account for project pages being migrated to Wiki
  [#GLEP39-20140119]_.


Establishing Council members
----------------------------
I have to say that of all management bodies considered, establishing
the Council members was the easiest task so far.  Thanks to single-year
terms combined with yearly elections, I was able to assemble most
of the table based on the published Council election results
[#COUNCIL-ELECTION-RESULTS]_ [#COUNCIL-ELECTION-CVS]_.

The Council meeting logs page includes summaries of all Council meetings
along with list of participants (Council members at the time)
[#COUNCIL-MEETING-LOGS]_.  Using this list, I have verified my earlier
results and established all the remaining mid-term seat changes,
the latter confirmed by actual meeting logs.

That's all.  I have easily assembled the complete list, and verified
each row with two sources.


Conclusion
----------
The Gentoo Council has been formed in 2005 as a part of new
metastructure.  It represents a shift from a hierarchical structure
where global decisions were made by privileged top-level project leads
to a system where Council is formed independently of project management,
and creating new projects is trivial.

The Council has dealt with many global issues, both technical
and social in nature.  It has been reviewing and approving various
proposals, including GLEPs, EAPIs (final approval) and other community
requests.  It has been asked multiple times to resolve technical
conflicts, override project decisions and review disciplinary actions.
However, it has never interfered with the Foundation affairs.

The majority of issues brought to the Council were technical in nature,
and that may have brought some developers to believe that the Council
is limited to deciding on technical issues.  In many cases, the requests
for the Council (that were not appeals) overlapped with the scope
of other projects in Gentoo, most notably Quality Assurance team.

The -nfp proposals of 2017 [#THODE-20170105]_ have started a new
discussion about the role of the Council in Gentoo.  It is possible that
the developers will eventually have to revisit the Gentoo metastructure
and reconsider the relation between Gentoo Foundation and Gentoo
developers.


The split of responsibilities
=============================
The following table tries to graphically summarize the split
of responsibilities between the business and the community part
of Gentoo in its history.

+-------+--------------------------------+-----------------------------+
| Term  |           Business             |          Community          |
+=======+==============+=================+===========+=================+
|       |              | Gentoo          |           |                 |
|       |              | Technologies    | Chief     |                 |
| -2004 |              | (president)     | Architect | Managers        |
|       |              +-----------------+-----------+-----+-----+-----+
|       |              |         Daniel Robbins      | ... | ... | ... |
+-------+--------------+-----------------+-----------+-----+-----+-----+
|       | Gentoo       | Gentoo          |                             |
|       | Technologies | Foundation      |                             |
| 2004  | (president)  | (Trustees)      | Managers                    |
| /05   +--------------+-----+-----+-----+-----+-----+-----+-----+-----+
|       | D Robbins    | ... | ... | ... | ... | ... | ... | ... | ... |
+-------+--------------+-----+-----+-----+-----+-----+-----+-----+-----+
|       |              | Gentoo          |                             |
|       |              | Foundation      |                             |
| 2005- |              +-----------------+                             |
|       |              | Trustees        | Council                     |
|       |              +-----+-----+-----+-----+-----+-----+-----+-----+
|       |              | ... | ... | ... | ... | ... | ... | ... | ... |
+-------+--------------+-----+-----+-----+-----+-----+-----+-----+-----+

It all started with Daniel Robbins who run both the business
and the community side of Gentoo.  The business part was originally
dealt with by Gentoo Technologies, Inc.

Over time, the community part grew and individual developers were
growing influence on the project.  Apparently, some of them had major
influence even before GLEP 4 was ratified.  Nevertheless, GLEP 4
provides the first visible metastructure, with a management team
consisting of a Chief Architect and a number of Managers.  At this
point, Daniel Robbins is the link between business and community part
of Gentoo, a personal union between the two worlds.

The year 2004 brings two significant changes.  Firstly, Daniel Robbins
resigns from his position of Chief Architect (and a future Trustee
seat).  Secondly, Gentoo Foundation is formed to take over business part
of Gentoo.  At this point, many Managers double the seat of a Trustee
and a Manager, prolonging the personal union.

The year 2005 finishes the transition from Gentoo Technologies to Gentoo
Foundation.  By the end of the year, Council is formed to replace
Managers.  For two terms to come, a few Council members double
as Trustees.  The union becomes weaker.

In 2008 there are no common members in both bodies left.  New Foundation
Bylaws explicitly forbid a single person from simultaneously serving
both as a Council member and a Trustee.  At this point, the both bodies
start going their separate ways.

While the early double-role of Daniel Robbins may have made the split
of responsibilities blurry, it was clearly visible since the inception
of Trustees.  Even with the shared members, both groups worked
independently — Trustees on setting up the legal and financial backing
of Gentoo, Council on solving the problems of the distribution and its
community.

The split between the business and community part probably became more
distinct due to Foundation having a separate member list.  Over time,
developers not interested in the business affairs of Gentoo have stopped
joining the Foundation.  Since 2008, the Foundation also started
admitting non-developer members which further diverged the member lists.

I have done a rough count of Foundation members by the end of April
2018.  To obtain more realistic numbers, I have assumed developer
retirements in progress to be already complete, as well as queued
Foundation member removals due to non-voting.  Out of 199 active
developers 72 were Foundation members (which accounts for approximately
36%).  At the same time, the Foundation had 5 non-developer members,
and 4 members that were recently retired developers (and who therefore
may no longer be active Foundation members as well).


Epilogue
========
This article started with a few simple questions: what was the relation
between past Council members and Trustees?  How many members did they
share in the past?  Did Gentoo developers move from Council to Trustees,
and the other way around?  Those questions gave birth to a table listing
past Council members and Trustees.

As I've been collecting the data, more ideas came.  If I already found
out that some of the Council seats were appointed rather than elected,
why not include that?  If we have this data for Council, why not include
it for Trustees as well?  If I have gotten that far already, why
not include the Managers as well?

The deeper I've got, the harder it was to obtain the data.  Even if I
were able to obtain some data, I needed to conduct deeper research
in order to interpret it correctly.  Finding Trustees forced me to go
through a lot of mails.  Figuring out Managers practically required me
to thoroughly research the metastructure at the time.

Having to find this much data on Top-level Management structure, it
seemed wasteful not to share it.  This in turn gave birth to this
article.  The history of Managers inevitably touched the beginnings
of Gentoo Foundation and the Council.  This naturally lead to extending
the article to those two management bodies as well, with their stories,
election specifics and member research details.

Once the article covered all the distinct bodies, comparisons between
them were the natural consequence.  After all, I've not only established
what their similarities and differences were but also in some cases
traced back the influence between them.

This is how a table grew into a long article on history of Gentoo
management.  It started by going in reverse chronological order
from the newest Council term, then changed into historical research
going in chronological order from establishing GLEP 4, eventually taking
a double run over the years of 2003-2018.

This story tells of the evolution of Gentoo project.  It started with
the growth of Gentoo developers' influence in the project.  The original
Gentoo Technologies company has been replaced by a not-for-profit run
entirely by the community.  The original top-level management structure
has been replaced with a Council elected among the developers.
The original personal union between business and community sphere
of Gentoo has been replaced by a bond of partnership.

Yet the process is far from finished.  Gentoo is a living body which
is still looking for ways to evolve.  It has its phases of stagnation
but it also has peaks of activity ready to dissolve the existing
metastructure and rebuild it into something new.  Changes are proposed
every once and then; many of them are forgotten but some of them add
to Gentoo's history.

Today's Gentoo organizational structure is the same structure
established in 2008, which in turn is the structure from 2005 with small
changes.  Tomorrow's Gentoo may have a ‘structure from 2008 with small
changes’, or it may be something completely different.  The only way
to find out is to wait and see.


Thanks
======
I would like to thank the following people who have contributed to this
article through providing me with additional data and helping
to understand the data I already had:

- David Abbott,
- Roy Bamford,
- Andreas K. Hüttel,
- Robin H. Johnson,
- Ulrich Müller,
- Alec Warner.


References
==========

.. [#MANAGEMENT-TABLE] Michał Górny, Gentoo management over time
   (https://dev.gentoo.org/~mgorny/articles/gentoo-management.html)

.. [#GLEP4] Daniel Robbins, GLEP 4: Gentoo top-level management
   structure proposal
   (https://www.gentoo.org/glep/glep-0004.html)

.. [#PROJECTS-STATIC] [gentoo] /xml/htdocs/proj/en/metastructure/projects.xml r1.1
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/metastructure/projects.xml?revision=1.1&view=markup)

.. [#PROJECTS-ARCHIVE] Gentoo metastructure project (archived 2005-03-08)
   (https://web.archive.org/web/20050308032336/http://www.gentoo.org:80/proj/en/metastructure/oldprojects.xml)

.. [#PROJECTS-DYNAMIC] [gentoo] /xml/htdocs/proj/en/metastructure/gentoo.xml
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/metastructure/gentoo.xml?view=log)

.. [#PROJECTS-ALLTLP] [gentoo] /xml/htdocs/proj/en/metastructure/gentoo.xml r1.7
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/metastructure/gentoo.xml?revision=1.7&view=markup)

.. [#PROJECTS-ALLMANAGERS] [gentoo] /xml/htdocs/proj/en/metastructure/gentoo.xml r1.8
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/metastructure/gentoo.xml?revision=1.8&view=markup)

.. [#ROBBINS-20030625] Daniel Robbins, [gentoo-dev] Re: [gentoo-core]
   *IMPORTANT* top-level management structure!
   (https://archives.gentoo.org/gentoo-dev/message/d36ceb1de1368999332ab2840f409abc)

.. [#ROBBINS-20030625-2] Daniel Robbins, [gentoo-dev] [drobbins@gentoo.org:
   Re: [gentoo-core] *IMPORTANT* top-level management structure!]
   (https://archives.gentoo.org/gentoo-dev/message/e6413db7da2f79999d536700b6324526)

.. [#HARDENED] [gentoo] /xml/htdocs/proj/en/hardened/index.xml r1.12
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/hardened/index.xml?revision=1.12&view=markup)

.. [#MANAGERS-20031215] [gentoo] /xml/htdocs/proj/en/devrel/manager-meetings/summaries/2003/20031215.xml r1.2
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/devrel/manager-meetings/summaries/2003/20031215.xml?hideattic=0&revision=1.2&view=markup)

.. [#ROBBINS-20030715] Re: [gentoo-dev] Gentoo part III?
   (https://archives.gentoo.org/gentoo-dev/message/65d46d9e7f4514275f5b3154db124a17)

.. [#GWN-20040517] [gentoo] /xml/htdocs/news/en/gwn/20040517-newsletter.txt r1.1
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/news/en/gwn/20040517-newsletter.txt?revision=1.1&view=markup)

.. [#DAVIS-20030715] John Davis, [gentoo-dev] Gentoo part II.
   (https://archives.gentoo.org/gentoo-dev/message/08a3ede681aa313dcda6b22b5bfdd810)

.. [#MANAGER-MEETING-LOGS] [gentoo] /xml/htdocs/proj/en/devrel/manager-meetings
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/devrel/manager-meetings/?hideattic=0)

.. [#GWN] [gentoo] /xml/htdocs/news/en/gwn
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/news/en/gwn/)

.. [#DE-VRIEZE-20031119] Paul de Vrieze, Re: [gentoo-dev] Gentoo
   internal structure
   (https://archives.gentoo.org/gentoo-dev/message/f37e321b1b6ec588de4d07e00f6d75c2)

.. [#ROBBINS-RESIGNATION] Daniel Robbins, [gentoo-nfp] Resigning from development role
   (https://archives.gentoo.org/gentoo-nfp/message/49f3cb71da20ee1eced4915c315fa8a2)

.. [#METASTRUCTURE-VOTE-RESULTS] [gentoo-dev] Metastructure vote preliminary results
   (https://archives.gentoo.org/gentoo-dev/message/f5ab9ccca62a5d5e0b7b7ab0156f19b3)

.. [#GLEP39] Grant Goodyear, Ciaran McCreesh, GLEP 39: An "old-school"
   metastructure proposal with "boot for being a slacker"
   (https://www.gentoo.org/glep/glep-0039.html)

.. [#COUNCIL-RESULTS-1] [gentoo-dev] Election results
   (https://archives.gentoo.org/gentoo-dev/message/3a1042167ebac103b9ffec5261ed6827)

.. [#COUNCIL-MEETING-1] [gentoo-dev] first council meeting
   (https://archives.gentoo.org/gentoo-dev/message/5dff5c2606b4c79392c51fd4e49dbeab)

.. [#MANAGERS-REMOVAL] Diff of /xml/htdocs/proj/en/metastructure/gentoo.xml;
   r1.18 to r1.19
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/metastructure/gentoo.xml?r1=1.18&r2=1.19)

.. [#TSENG-RETIREMENT] Retire: Brandon Hale (tseng)
   (https://bugs.gentoo.org/118218)

.. [#ZYNOT-REASONS-FOR-FORKING] Zachary T Welch, Reasons for Forking
   A Linux Distribution (archived 2003-07-07)
   (http://web.archive.org/web/20030707080226/http://www.zynot.org/info/fork.html)

.. [#ROBBINS-20040416] Daniel Robbins, [gentoo-nfp] I met with my lawyer
   (https://archives.gentoo.org/gentoo-nfp/message/d5c3593a859b319725e2c11192eb87c8)

.. [#FOUNDATION-AOI] Gentoo Foundation Inc., Articles of Incorporation
   (https://wiki.gentoo.org/wiki/Foundation:Articles_of_Incorporation)

.. [#VERMEULEN-20041021] Sven Vermeulen, [gentoo-nfp] Status Update
   of the Gentoo Foundation
   (https://archives.gentoo.org/gentoo-nfp/message/24adbb5301b339663963fa203da51cae)

.. [#GOODYEAR-20041201] Grant Goodyear, [gentoo-trustees] Re: [PSF-Board]
   Requesting permission to use parts of bylaws for Gentoo
   (https://archives.gentoo.org/gentoo-trustees/message/ba6b2276db75336eb0023780a659e1a6)

.. [#BYLAWS-DRAFT] [gentoo] /xml/htdocs/foundation/en/bylaws.xml r1.1
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/foundation/en/bylaws.xml?hideattic=0&revision=1.1&view=markup)

.. [#GOODYEAR-20050411] Grant Goodyear, [gentoo-nfp] Upcoming elections
   (https://archives.gentoo.org/gentoo-nfp/message/423ad420aabbd6230c98ccdb7684d598)

.. [#GOODYEAR-20050416] Grant Goodyear, [gentoo-nfp] Foundation
   membership and trustee election.
   (https://archives.gentoo.org/gentoo-nfp/message/6ea628934ddeff51c44715255d642c35)

.. [#GOODYEAR-20050427] Grant Goodyear, [gentoo-nfp] Thoughts
   on upcoming trustee elections
   (https://archives.gentoo.org/gentoo-nfp/message/74f98cf099bd737e4cb931be978f1f16)

.. [#GRIFFIS-20050428] Aron Griffis, Re: [gentoo-nfp] Thoughts
   on upcoming trustee elections
   (https://archives.gentoo.org/gentoo-nfp/message/2565c6653b5cf76e55689ffb0f87ddca)

.. [#GOODYEAR-20050521] [gentoo-nfp] Transfer of copyrights and marks
   (https://archives.gentoo.org/gentoo-nfp/message/0558f4bbba7ff2a666edded0669be724)

.. [#GOODYEAR-20050914] [gentoo-nfp] "Gentoo" registered trademark
   (https://archives.gentoo.org/gentoo-nfp/message/9b3ed16aa3bbd2135243680a83872d8b)

.. [#GOODYEAR-20060706] Grant Goodyear, [gentoo-nfp] Re: [gentoo-core]
   Nominations?
   (https://archives.gentoo.org/gentoo-nfp/message/e0f33eb9579f0083dda1abe0e69cc844)

.. [#KULLEEN-20060905] [gentoo-dev] Trustees Announcement
   (https://archives.gentoo.org/gentoo-dev/message/b6814d46849a6811808509289c6485f7)

.. [#KULLEEN-20060923] Seemant Kulleen, [gentoo-nfp] Trustee Elections 2006
   (part II)
   (https://archives.gentoo.org/gentoo-nfp/message/0c7a6bd52a2ba19174caba9c41f72371)

.. [#GOODYEAR-20061021] Grant Goodyear, [gentoo-nfp]
   [nattfodd@gentoo.org: [gentoo-core] Trustees 2006 election results]
   (https://archives.gentoo.org/gentoo-nfp/message/0504696c146ae3ad92e63f5b810c8353)

.. [#KULLEEN-20061023] Seemant Kulleen, [gentoo-nfp] New Trustees
   - My Resignation
   (https://archives.gentoo.org/gentoo-nfp/message/4cbddb6562e24d579041504c8de27496)

.. [#HERBERT-20061129] Stuart Herbert, [gentoo-nfp] Resignation
   (https://archives.gentoo.org/gentoo-nfp/message/3da6e0f5eb6869fa08f0530c7897b769)

.. [#GIANELLONI-20070731] Chris Gianelloni, [gentoo-nfp] Possible scenario
   for '07/'08 Trustees
   (https://archives.gentoo.org/gentoo-nfp/message/a610308b572886f9e70b2fe6f6a5b6cb)

.. [#GOODYEAR-20070926] Grant Goodyear, [gentoo-nfp] update
   (https://archives.gentoo.org/gentoo-nfp/message/4bfe3d934ede38397f108b9d8f4b1321)

.. [#ROBBINS-20080111] Daniel Robbins, And it gets worse...
   (archived 2010-06-08)
   (http://web.archive.org/web/20100608140450/http://blog.funtoo.org:80/2008/01/and-it-gets-worse.html)

.. [#GOODYEAR-20080119] Grant Goodyear, [gentoo-nfp] Foundation update
   (https://archives.gentoo.org/gentoo-nfp/message/ef3914ff65576a0578d58634e7811c8e)

.. [#VICETTO-20080229] Jorge Manuel B. S. Vicetto,
   [gentoo-nfp] Fwd: Gentoo Foundation 2008 Elections - Results
   (https://archives.gentoo.org/gentoo-nfp/message/600696caa6b5ab9744b29a1df8f427be)

.. [#THOMSON-20080513] William L. Thomson Jr.,
   [gentoo-nfp] Foundation reinstated
   (https://archives.gentoo.org/gentoo-nfp/message/d2632d76e6582187bb1816897bb81ffd)

.. [#BYLAWS-20080831] [gentoo] /xml/htdocs/foundation/en/BylawsAdopted.xml r1.1
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/foundation/en/BylawsAdopted.xml?hideattic=0&revision=1.1&view=markup)

.. [#TRUSTEE-MEETING-200808] August 2008 Trustee meeting log
   (https://projects.gentoo.org/foundation/2008/august2008.txt)

.. [#SUMMERS-20081117] Matthew Summers, [gentoo-nfp] Foundation
   Membership Announcement and Application Information
   (https://archives.gentoo.org/gentoo-nfp/message/57b10a66bb0c3b6b38ed69b852d941e3)

.. [#BYLAWS-20081116] [gentoo] /xml/htdocs/foundation/en/BylawsAdopted.xml r1.2
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/foundation/en/BylawsAdopted.xml?hideattic=0&revision=1.2&view=markup)

.. [#THOMSON-20110328] William L. Thomson Jr., [gentoo-nfp] List of items
   to be addressed by audit
   (https://archives.gentoo.org/gentoo-nfp/message/b937891f5b89959d0dc79167fec5ae44)

.. [#SUMMERS-20111117] Matthew Summers, [gentoo-nfp] 2011 NMPRC Filing
   (https://archives.gentoo.org/gentoo-nfp/message/b1d89cc7b2c13584cd185676a7059193)

.. [#FREEMAN-20121217] Rich Freeman, [gentoo-nfp] Soliciting Feedback:
   Gentoo Copyright Assignments / Licensing
   (https://archives.gentoo.org/gentoo-nfp/message/75fe33aaf71d0be9f82aaf1eea9e76cb)

.. [#THODE-20161013] Matthew Thode, [gentoo-nfp] Foundation membership
   and who can join
   (https://archives.gentoo.org/gentoo-nfp/message/775328e1c45fbf410da3cd03c065e2b9)

.. [#JOHNSON-20161013] Robin H. Johnson, [gentoo-nfp] Bylaw proposal:
   Amend Section 4.3. Admission of Members: automatic developer membership
   (https://archives.gentoo.org/gentoo-nfp/message/862113eba01f66bfbba71ec4f5162c5a)

.. [#WARNER-20161107] Alec Warner, [gentoo-nfp] Next meeting; a motion
   to have 1 type of Gentoo member.
   (https://archives.gentoo.org/gentoo-nfp/message/ef040f14ce54d2ce461eb5ad32400579)

.. [#PALIMAKA-20161109] Michael Palimaka, [gentoo-nfp] Re: Next meeting;
   a motion to have 1 type of Gentoo member.
   (https://archives.gentoo.org/gentoo-nfp/message/eec297a3a7d1803c4579ec10e894822b)

.. [#THODE-20170105] Matthew Thode, [gentoo-nfp] Merging Trustees
   and Council / Developers and Foundation
   (https://archives.gentoo.org/gentoo-nfp/message/b094364b1e059218000f9d9c5654297a)

.. [#BYLAWS-20170619] Foundation Bylaws (version from 2017-06-19)
   (https://wiki.gentoo.org/index.php?title=Foundation:Bylaws&oldid=650466)

.. [#TRUSTEE-ELECTION-RESULTS] Gentoo Trustee elections
   (https://wiki.gentoo.org/wiki/Project:Elections/Trustees#Gentoo_Trustee_elections_2)

.. [#ELECTION-GIT] proj/elections.git: Gentoo Elections control data
   (https://gitweb.gentoo.org/proj/elections.git/)

.. [#TRUSTEE-ELECTION-CVS] [gentoo] /xml/htdocs/proj/en/elections/trustees
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/elections/trustees/)

.. [#FOUNDATION-WIKI] Foundation:Main Page - Gentoo Wiki
   (https://wiki.gentoo.org/wiki/Foundation:Main_Page)

.. [#FOUNDATION-GUIDEXML] [gentoo] /xml/htdocs/foundation/en/index.xml
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/foundation/en/index.xml?view=log)

.. [#GORNY-20180517] Michał Górny, [gentoo-nfp] Trying to figure out
   Trustee elections 2014-2016
   (https://archives.gentoo.org/gentoo-nfp/message/6ed8eb7af6a767424af59362d3d05c8e)

.. [#MCCREESH-20060905] Ciaran McCreesh, Re: [gentoo-dev] Trustees Announcement
   (https://archives.gentoo.org/gentoo-dev/message/83f2db5a36b7abe1b3d004991081041f)

.. [#GORNY-20180418] Michał Górny, [gentoo-nfp] New Trustee voting proposal
   (including _reopen_nominations)
   (https://archives.gentoo.org/gentoo-nfp/message/1cf0c52c0ffd6cad6f914ac46e87a233)

.. [#JOINT-MEETING-20180120] Joint Council&Trustee meeting 2018-01-20
   (https://projects.gentoo.org/council/meeting-logs/20180120.txt)

.. [#METASTRUCTURE-VOTE] Daniel Drake, [gentoo-dev] Gentoo metastructure
   reform poll is open
   (https://archives.gentoo.org/gentoo-dev/message/889310a392bdc9306ff9a2bffe0e4642)

.. [#METASTRUCTURE-FOSDEM] FOSDEM 2005 Metastructure proposal
   (https://wiki.gentoo.org/wiki/Project:Council/Metastructure_reform_2005/FOSDEM)

.. [#METASTRUCTURE-ALTERNATIVE] Thierry Carrez, Alternative Metastructure
   proposal
   (https://wiki.gentoo.org/wiki/Project:Council/Metastructure_reform_2005/Alternative)

.. [#METASTRUCTURE-OLDSCHOOL] Grant Goodyear, An "old-school" metastructure
   proposal
   (https://wiki.gentoo.org/wiki/Project:Council/Metastructure_reform_2005/Oldschool)

.. [#METASTRUCTURE-SLACKER-BOOT] Ciaran McCreesh, Re: [gentoo-core] Gentoo
   Metastructure -- Last call for reform proposals / May 30, 23:59 UTC
   (https://wiki.gentoo.org/wiki/Project:Council/Metastructure_reform_2005/Slacker-boot)

.. [#METASTRUCTURE-TASKFORCE] Daniel Drake, Re: [gentoo-dev] Gentoo
   metastructure reform poll is open
   (https://wiki.gentoo.org/wiki/Project:Council/Metastructure_reform_2005/Task-force)

.. [#COUNCIL-NOMINATIONS-2006] Mike Frysinger, [gentoo-dev] Nominations
   open for the Gentoo Council 2007
   (https://archives.gentoo.org/gentoo-dev/message/aa073f4053fdeffde9f3e4c404a89c6a)

.. [#COUNCIL-NOMINATIONS-2008B] Jorge Manuel B. S. Vicetto,
   [gentoo-council] Gentoo Council nominations are now closed
   (https://archives.gentoo.org/gentoo-council/message/eab0ab605f91e4d1aa196fd5891dd0ec)

.. [#COUNCIL-DECISIONS] A. K. Hüttel, Council decision and summary overview
   (https://dev.gentoo.org/~dilfridge/decisions.pdf)

.. [#COUNCIL-20060112] Council meeting log for 2006-01-12
   (https://projects.gentoo.org/council/meeting-logs/20060112-summary.txt)

.. [#GLEP39-20060209] data/glep.git, cb52ae71f77de2d1200a696eb7296e69cf657c60
   (https://gitweb.gentoo.org/data/glep.git/commit/?id=cb52ae71f77de2d1200a696eb7296e69cf657c60)

.. [#COUNCIL-20070315] Council meeting log for 2007-03-15
   (https://projects.gentoo.org/council/meeting-logs/20070315-summary.txt)

.. [#COUNCIL-20070614] Council meeting log for 2007-06-14
   (https://projects.gentoo.org/council/meeting-logs/20070614-summary.txt)

.. [#COUNCIL-20071011] Council meeting log for 2007-10-11
   (https://projects.gentoo.org/council/meeting-logs/20071011-summary.txt)

.. [#GLEP39-20071012] data/glep.git, c82fe1a98c374714f0f178f5543a5dd5fb0c70b0
   (https://gitweb.gentoo.org/data/glep.git/commit/?id=c82fe1a98c374714f0f178f5543a5dd5fb0c70b0)

.. [#COUNCIL-20080911] Council meeting log for 2008-09-11
   (https://projects.gentoo.org/council/meeting-logs/20080911-summary.txt)

.. [#COUNCIL-20100809] Council meeting log for 2010-08-09
   (https://projects.gentoo.org/council/meeting-logs/20100809-summary.txt)

.. [#GLEP39-20140119] GLEP 39, Revision as of 2014-01-19T14:50:19
   (https://wiki.gentoo.org/index.php?title=GLEP:39&oldid=99195)

.. [#COUNCIL-ELECTION-RESULTS] Gentoo Council elections
   (https://wiki.gentoo.org/wiki/Project:Elections/Council)

.. [#COUNCIL-ELECTION-CVS] [gentoo] /xml/htdocs/proj/en/elections/council
   (https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo/xml/htdocs/proj/en/elections/council/)

.. [#COUNCIL-MEETING-LOGS] Council Meeting logs - Gentoo Wiki
   (https://wiki.gentoo.org/wiki/Project:Council/Meeting_logs)
