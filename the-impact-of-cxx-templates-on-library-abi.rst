==========================================
The impact of C++ templates on library ABI
==========================================
:Author: Michał Górny
:Date: 20 Aug 2012
:Copyright: http://creativecommons.org/licenses/by/3.0/


Preamble
========

The general aspect of maintaining binary compatibility of C++ library
interfaces has been already covered thoroughly multiple times.
A good reference of articles on the topic can be found on wiki page
of `ABI compliance checker` tool [1]_. Sadly, those articles usually
consider the topic of C++ templates only briefly, if at all.

While in fact the topic is fairly complex, and I believe that
considering the overall usefulness and popularity of the templates, it
should be considered more thoroughly. Thus, in this article I will try
to address the issues arising from use of templates, methods of dealing
with them and trying to prevent them.

Both the overall topic of templates in respect to the programming
techniques, and the wide topic of ABI are already explained in detail
in many other articles and guides. Moreover, I believe that myself I am
not fluent enough to be able to cover those topics in detail here. Thus,
I will assume that a reader of this article is already familiar with
both the general topic of templates in C++, and the basic aspects of
an ABI and its compatibility.

Moreover, in the solutions and problems listed here I will assume that
a particular toolchain in question does conform to the C++98 standard,
and is able to properly support templates with regard to multiple
instantiations.

.. [1] http://ispras.linuxbase.org/index.php/ABI_compliance_checker#Articles


ABI consistency in regular functions and class methods
======================================================

Before proceeding further, I wish to quickly summarize the aspects
of ABI compliance in regard to regular (`non-template` and `non-inline`)
functions and class methods.

In shared libraries, the interface of library functions is defined
within the header files which are installed along with the library.
The implementation code, however, is defined in the source files which
are compiled into the shared library itself. Effectively,
the implementation is kept opaque to the library consumers; and those
consumers (either programs or other shared libraries) dynamically link
to the library [2]_.

Nevertheless, if the function ABI is to change, such a change can be
signaled through changing the `SONAME` of the library. As executables
and other shared libraries are linked to a specific `SONAME`, they have
to be rebuilt in order to use the new version of the library. That way,
it is ensured that the consumers will be rebuilt to use the new ABI
before using the library.

Effectively, it is quite straightforward to maintain the ABI of a shared
library using regular functions and classes. The number of ABI changes
is minimized through keeping the implementation opaque to
the consumers; and the actual ABI changes are propagated through use
of `SONAME` and other symbol versioning techniques.

.. [2] The topic of static linking is not covered here as of no
       relevance.


The problem of handling template functions and classes
======================================================

The requirements put on the compiler for template support made
the solution presented above no longer possible. In order to achieve
generic programming, the compiler must be able to adjust both
the interface and the implementation of template functions and classes
according to the template arguments. Considering that those arguments
can practically hold any consumer-provided type or value (including
types defined by consumers themselves), it is no longer possible to
precompile the implementation code and provide it in a opaque shared
library.

A completely different solutions need to be used in order to support
templates. Firstly, both the interface and the implementation code must
be public to the consumers; thus both are provided in the headers
installed by the library. Effectively, a number of C++ libraries, Eigen
[3]_ for instance, actually consist of header files only.

Secondly, compiler must be able to instantiate and compile the templates
at will. Unlike with regular function which are compiled within a single
source unit, templates have to be compiled on use, and can be used in
multiple independent files. Effectively, the compiler must be able to
handle multiple definitions of the same template sanely.

To sum up, templates basically no longer form a uniform shared library.
They are propagated through header files, and can be instantiated
practically anywhere — either in the library providing them (through use
in other functions, or through forced instantiation), in a shared
library using them or in the final executable. Moreover, the same
template can be instantiated in multiple locations at the same time.
The implementation part can no longer be opaque, and is spread along
with the instantiations.

The lack of ability to provide opaque implementation makes it harder to
change the code without breaking ABI compatibility. Moreover,
the decentralization makes it even harder both to propagate
implementation changes (including bug fixes) and to handle ABI changes.

.. [3] http://eigen.tuxfamily.org/


Avoiding multiple, incompatible instantiations
==============================================

One of the most common issues being result of a library ABI change is
the occurrence of multiple, incompatible instantiations of the same
template. I will explain this on a recent example.

With the recent improvement of C++11 standard support in gcc 4.7.1,
the ``std::list<T>`` template class has been changed to hold the list
length. The change has been made conditional to the C++11 standard being
enabled; effectively, to the ``-std=c++11`` option [4]_.

Now, if I have a particular program which uses ``std::list<int>``,
and I compile that program in the C++11 mode, the extended template will
be used. To that moment, everything is fine.

However, if I would like to use a shared library using
``std::list<int>`` as well, and that library is compiled for another C++
standard (``-std=c++98``, for example), the program may no longer work
correctly.

This is because both the program executable and the shared library would
try to instantiate an incompatible versions of ``std::list<int>``. Only
one of those versions will be actually used, and the code written for
the other one may break randomly.

The main issue solving that incompatibility is that if the library
providing the template is based only on header files, it is no longer
able to enforce propagation of the ABI change through rebuilding all of
the libraries and executables using it.

.. [4] As a side note, the change has been reverted and postponed
       to be introduced unconditionally in the next standard C++ library
       version.

Using templates in final executables only
-----------------------------------------

A one particular way in which the problem could be avoided is to limit
the template instantiation to a single executable. For practical
reasons, that executable would supposedly be the final program
executable, allowing the programmer to use templates freely and all
the libraries to use them equally.

This can be achieved through making all the implementation using
templates… a template as well. For example, consider the following
code::

	#include <vector>

	class C
	{
	public:
		int f();

		// ...
	};

	int C::f()
	{
		std::vector<int> value_vector;

		// ...
	}

Here function `f()` from class `C` uses a ``std::vector<int>``
internally. In order to avoid local instantiation of the vector, we need
to make the class `C` a template class. In this particular case, we can
achieve an additional benefit from that — allowing the user to specify
the allocator for `value_vector`::

	#include <memory>
	#include <vector>

	template < class allocator = std::allocator<void> >
	class C
	{
	public:
		int f()
		{
			typedef typename allocator::template rebind<int>
				::other alloc_type;
			std::vector<int, alloc_type> value_vector;

			// ...
		}
	};

This way, as long as all classes using `C` are templates as well,
the only template instantiation will take place in the final executable
where the last template class is used. Of course, this has many
implications for quite a little benefit. Most importantly:

- all template classes have to be used along with template parameters;
  instead of ``C``, one has to use ``C<>``;
- all template classes have to make the implementation public,
  and start to suffer from all template-related issues explained here;
- the code generation is deferred to the final executable. Code
  duplication occurs, shared libraries no longer serve a purpose
  and compiling the program becomes time- and memory-consuming.

Just as a note, the fore-mentioned approach can be used when there is no
logical use for a template as well. An unused template parameter can be
introduced then::

	template <int unused = 0>
	class C
	{
		// ...
	};

Using custom types in shared library templates
----------------------------------------------

An alternate and possibly better approach is to prevent non-local
instantiations of a particular template specializations through scoping
of the types used in them.

Please consider the following example::

	#include <list>

	// class C is a public class provided by the library

	void f()
	{
		std::list<C> l;

		// ...
	}

Here, the ``std::list<C>`` template is instantiated. However, the type
`C` is part of the public library API and an API consumer may want to
create a list of that type as well. In order to avoid the list being
instantiated twice, the library may replace `C` with a local-scope
derived class::

	#include <list>

	namespace
	{
		class C_ : public C
		{
			// ...
		};
	};

	void f()
	{
		std::list<C_> l;

		// ...
	}

Since `C` and `C_` are distinct types, ``std::list<C_>`` will
instantiate a different specialization than ``std::list<C>``.
And as `C_` is limited to the local scope, no consumer should be able to
create a list of that type.

Using inline methods and functions
----------------------------------

There is one more solution which I am ought to mention, yet its use is
limited and it is not guaranteed to work at all. The one remaining way
of preventing multiple instantiations is to enforce inline instantiations
of template methods.

This approach has a few limitations. Firstly, it requires modifying
the template itself, so it won't work with external templates, like
fore-mentioned ``std::list``. Additionally, since the compiler is free to
ignore the `inline` keyword at will, this solution may only work
partially or not work at all.

For completeness, I will present an example::

	template <class T>
	class C
	{
		T sth;

	public:
		inline T& get()
		{
			return sth;
		}

		inline void set(T& new_val)
		{
			sth = new_val;
		}
	};

The above code uses the `inline` keyword extensively, hoping that
the compiler will inline all the method calls rather than instantiating
them as separate methods. If it succeeds for all of the methods,
external instantiations will not have anything to collide with.


Achieving a (partially) opaque implementation with templates
============================================================

While the solutions listed above address a real issue, none of them
could be considered a really good solution. They mostly try to
circumvent a specific issue rather than addressing the deeper one which
I would like to point out.

Those solutions are good as long as we're only interested in keeping
the executables `mostly` working. However, the template library works
alike a `static library` there, suffering from the same limitations that
a static library has.

Most importantly, it is impossible to change the implementation
of a particular function or method, and propagate the change without
rebuilding all the libraries and programs using the template. And this
becomes important if the particular code suffers from security
vulnerabilities or bugs which could result in data loss.

In order to solve that problem, we need to take a step back and see what
can we do to make template implementation more opaque once again.

Explicitly instantiating opaque templates
-----------------------------------------

One particular solution which solves the issue completely is to keep
the implementation completely opaque, and force the compiler to
explicitly instantiate necessary templates. However, a very important
disadvantage of this solution is that the possible uses of the template
are limited to the ones provided by the library.

For an example, please consider we're having a ``MyList<T>`` container
which works similarly to ``std::list<T>``. In order to make the list
implementation opaque, the header files contain only the interface
of ``MyList<T>``::

	template <class T>
	class MyList
	{
		struct priv_type;
		priv_type* priv;

	public:
		// ...
	};

As you can see in the above example, the PImpl (`private
implementation`) idiom is used there to hide the private class members.
That kind of PImpl implementation does not make sense with regular
templates, since the private members would have to be explicitly listed
along with the implementation. However, in this case we are keeping
the implementation private.

The implementation along with the supported instantiations is provided
in the source file of the library::

	#include "mylist"

	template class MyList<int>;
	template class MyList<double>;
	template class MyList<void*>;

	// ...

With the above declarations, followed by the method and `struct
priv_type` implementations will result in compiler outputting
the template code for `int`, `double` and `void*` types. That code will
be placed in the shared library, and made available for the consumers
of the shared library.

Now, if a consumer uses ``MyList<int>`` and links to the shared library,
it will use the opaque implementation from the library. Alike with
regular functions, any ABI-safe changes will be propagated
to the programs; and ABI-unsafe will result in necessity of rebuilding
them, propagated through `SONAME` change.

However, if the consumer decides to use ``MyList<char>``, the compiler
will no longer be able to satisfy that requirement. The linker will
refuse to link the program because of no implementation
of ``MyList<char>`` methods.

Using common base classes and functions
---------------------------------------

Sadly, the fore-mentioned approach limits the possible uses
of the template to a predefined parameter sets. This may be acceptable
in very specific cases but usually it just invalidates the whole point
of using templates.

An alternative approach is to use a partially opaque implementation,
with the opaque being subject to `easy` implementation changes,
and the public behaving like a regular template. This could be
accomplished in a number of ways.

One of them is to develop a common, opaque base class which performs
the most important tasks in a type-agnostic way and a derived template
class which wraps the former in a nice API. For example, consider
a pointer list like the following::

	template <class T>
	class PointerList;

	template <>
	class PointerList<void>
	{
		struct priv_data;
		priv_data* priv;

	public:
		// ...
	};

	template <class T>
	class PointerList
		: private PointerList<void>
	{
	public:
		// ...
	};

The pointer list template is first specialized for the ``void*`` type.
That specialization uses a PImpl idiom, private code and explicit
instantiation (in the source file) to provide an opaque implementation
of ``void*`` pointer list. On top of that, a public generic pointer list
template is built.

With such a solution, the most important parts of implementation
(in this case that would be the list handling code) are kept opaque,
and thus changes in that code are propagated the usual way.
The remaining public parts (in this case, that part would probably just
cast types) suffer the regular issues with template classes.

It should be noted that the example presented above was very optimistic.
Usually, providing a common opaque implementation is a more demanding
task. Sometimes even it is not possible to split out a common amount of
code for the base class, and only small pieces of code could be
considered common. In these cases, the presented approach may not be
beneficial at all.


Enforcing ABI versioning with template libraries
================================================

Up to the moment, I have mostly considered avoiding issues resulting
from ABI incompatibilities, and avoiding introducing those
incompatibilities. But even if the author protects executables from
the fore-mentioned issues and provides a mostly-opaque implementation, he
should still prepare the library for future ABI (or implementation)
changes.

As mentioned before, the most common method used in POSIX-compliant
systems is based on `interface versioning` (or even a more fine-grained
`symbol versioning` in GNU systems). The concept is mostly
straightforward — a shared library declares a range of supported
interface versions, and the programs linking against it copy the current
version into themselves. When the library is upgraded, and does not
support the old interface anymore, the interface version in programs
does not match the one in the library, and they refuse to use it without
being rebuilt.

Although this technique is used in regular C and C++ libraries to handle
ABI changes (effectively propagating the ABI change to consumers), it
can be used to enforce implementation changes for templates as well.
This can become particularly useful if a particular template code
suffers from serious vulnerabilities or bugs.

The `--as-needed` problem
-------------------------

The fore-mentioned interface versioning technique requires the program
using templates to link against a shared library where the version is
defined. This becomes problematic if the template class does not use
opaque implementation in the used code (i.e. all methods used by
a particular consumer are defined in the template) and the `--as-needed`
GNU linker option is used.

The intent of that option is to link the program executable only with
those libraries which it uses directly. Although this often is
advantageous and thus the option gained popularity, it thwarts
our plans. Because the code using the templates does not call
any function from the library we are forcing it to link, the linker will
simply skip that library. Effectively, the `ABI link` will be broken,
and interface changes from the library won't be propagated to template
consumers.

Although this specific problem could supposedly be worked around through
disabling that option, that is not really feasible in this case. Most
importantly, the task of disabling it would either need to be done by
the library consumers directly (effectively, making it unlikely
to happen) or handled through an external ``-config`` application which
will hurt cross-compilation.

To cover the topic completely, I'll note that such a solution would
first have to check whether `--as-needed` is actually enabled. And due
to the specific synopsis of `-Wl` compiler option, finding that would be
a semi-difficult task (and different compilers will have different
options). Then, it would have to add `-Wl,--no-as-needed`, the relevant
libraries and re-enable `-Wl,--as-needed`.

Since that thing is neither easy to implement, nor portable, and we
can't forget that other (future) linkers can inhibit similar behavior
using different options or even unconditionally, I believe we should
look for another solution. One which works around the actual issue
rather than trying to disable the feature exposing it.

Using dummy symbols to enforce linking
--------------------------------------

As mentioned earlier, the reason why linker silently ignores our library
is that the program doesn't actually use any symbol from it. So, in
order to work around that, we simply need to define a dummy symbol
and use it. Although that may look simple at first, we should give it
some thought.

First of all, considering that the symbol has no real meaning, we should
try hard to avoid unnecessary impact on the code, both in terms of
performance and its size. Preferably, it should be as short as possible,
and it should appear on unused (or likely-unused) code paths. However,
we should also make sure that the code will actually be reachable —
and thus the compiler won't optimize it out.

For example, an obvious solution seems to add a ``dummy()`` method to
our template class, and access the symbol there. Sadly, since the method
is never actually used, the compiler doesn't even instantiate it. After
some thinking, you may reach a consensus that the only safe place for
the call is in the constructor or destructor — but if the template class
is used as a static class, these may not be used as well.

I described a similar problem on stackoverflow [5]_, and was given
a pretty good tip there. Thanks to that, I assembled the following
universal solution::

	namespace mylib
	{
		extern int dummy;

		namespace
		{
			class Dummy
			{
			public:
				inline Dummy()
				{
					dummy = 0;
				}
			};

			static const Dummy dummy;
		}
	}

With the ``int dummy`` variable being declared in the library code.
The main (and possibly the only one) advantage of that solution is that
it works with any code. The variable setting code may have side effects,
thus the compiler is not allowed to optimize it out. It can however
practically optimize it to a single ``mov`` instruction.

The disadvantage of that solution is that the assignment operation will
be performed once for every single file including the header file. Thus,
I would consider the fore-mentioned solution as a last resort, while
preferring placing similar assignments in rarely-used (but always
compiled) code, whenever possible.

For example, such a code may be within a rare error or exception
handler. Just make sure that the compiler will not be allowed to assume
that a particular branch will never be executed. For example,
the following may be a bad idea::

	template <type T>
	void C<T>::f(int always_one = 1)
	{
		if (always_one != 1)
		{
			dummy = 0;
			throw MyException();
		}

		// ...
	}

Although most likely this code will work as expected, if a compiler
decides to inline the function it may notice that it is always called
with `1`, effectively removing the whole branch. Similarly, the code
should not be placed in unreachable code (because compiler may notice
that) or assertions (because with `NDEBUG` they will be removed).
And don't forget that if `f()` will not be used directly at all,
the whole function can be optimized out.

To sum up: if you have a safe, unlikely-called branch in your code, then
it's the best place for the assignment. If you don't have one, then
universal solution is probably the best you can get. Although it will
cause unnecessary repetitions of the assignments, every other place is
likely to cause even larger number of them.

.. [5] http://stackoverflow.com/questions/11917014/enforce-linking-with-a-shared-library-with-wl-as-needed-when-only-templates


A short summary
===============

In this article I tried to point out a few common problems related to
the ABI in shared libraries using templates. Firstly, I'd like to note
I've focused only on issues arising from their use in the implementation
code of a library, without exposing them in the public API.

If templates are exposed in the public API, i.e. used as function
arguments or return types, their impact increases rapidly. In that case
they become part of the library ABI, and changes in them effectively
change the ABI of the library itself. There are solutions which try to
avoid that, for example the bridge pattern [6]_ but they're out of scope
of this article.

Still, all the fore-mentioned issues apply. When designing a library
of templates, you should be aware of them and know how to handle them.
Most importantly, I believe that you should always be aware that your
ABI may change at some point, even if it is very simple and dedicated to
a very specific solution, and even if you are going to make it opaque,
or take other precautions to avoid it changing in the future.

Thus, the important point here is to design your library in such a way
that its consumers will be able to handle these ABI changes gracefully.
The second but nevertheless important problem is actually avoiding ABI
changes, either by good design (if possible) or through introducing new
classes or methods rather than modifying the existing ones.

However, note that the latter method mentioned is going to require you
to either permanently duplicate code (and effectively allowing
the consumers to still use the old one), or just delay the ABI change
until the compatibility code is removed in favor of requiring your
consumers to update their code, thus effectively changing both the API
and the ABI.

.. [6] http://en.wikipedia.org/wiki/Bridge_pattern


.. vim:ft=rst:tw=72:fenc=utf8:noet:spell:spelllang=en_us
