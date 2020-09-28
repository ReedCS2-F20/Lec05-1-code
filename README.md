### CSCI 221 Fall 2020
# Lecture 05-1: linked lists

---
 
This is a repository for the lecture materials from 9/28/2020, including
supplemental information on the `make`, `gdb`, and `lldb` tools. 

--

This folder contains an implementation of a linked list *library*, as
implemented in the two source files `llist.hh` and `llist.cc`. Neither
of these files have a `main` in them. Instead, they can be compiled
with other program source code that needs to use a linked list to
structure its data. (This is often called the *client code* to the
`llist` library we've invented.) This folder also contains a sample
client program, the source file `test_llist.cc` that is simply a
"driver" program that can be used to test the linked list code.

### Running the code

The code in this repo can be compiled with the unix command line

    g++ --std=c++11 -g -o test_llist test_llist.c llist.cc

and then run with the unix command line

    ./test_llist <values>

where `<values>` is either nothing, or a space-separated list of
integers that get used as the contents of a linked list, first built
by the program.

Once running, the program asks for a series of commands, ones that
perform a suite of operations on that linked list. For example, here
is an interaction made possible by the program:

    $ ./test_llist 5 7 3
    Your list is [5, 7, 3].
    Enter a list command: insert end 42
    Done.
    Your list is [5, 7, 3, 42].
    Enter a list command: delete front
    Done.
    Your list is [7, 3, 42].
    Enter a list command: search 5
    Not found.
    Your list is [7, 3, 42].
    Enter a list command: quit
    Bye!
    $

The set of commands it accepts is reported by the `help` command and
is the following:
 
    insert front <number>
    insert end <number>
    delete front
    delete end
    search <number>
    help
    quit
 
### Debugging linked list code

There are several tricky things about writing C++ code that operates
on with pointers. The most frequent bug in your code that you'll
encounter is a `Segmentation fault.` This arises when you attempt to
access the `data` or `next` field of a `node*`, say for example, with
expressions like `list->first->data` or `current->next`.  In each (see
the `llist` code) the expressions `list->first` and `current` are each
of type `node*`, so they could each be pointing to a valid struct of
type `node`.  Or it's possible that each could be a `nullptr`.

I've trained myself, when writing linked list code, to worry quite a
bit any time my code accesses one of these fields. When I type
`->data` or `->next` an alarm goes off in my coding mind, asking the
question "*Could this pointer be null??*" I then work hard to either
(a) convince myself that the line of code cannot face that situation,
that I've eliminated the `nullptr` scenario by handling such cases
with conditional statements (or, because the condition on my loop
prevents that scenario within its body). Or (b) I realize that a
`nullptr` is actually possible at that moment, and develop more
complex code that handles that case.

Nevertheless, I still make mistakes, and so there are a few strategies
I use for figuring out the cause of a segmentation fault. One useful
strategy is to add output lines before and after lines of code that
are suspect. You can, for example, output the value of a pointer using
`std::cout <<` just before a line that relies on a pointer being valid.
If the output is the `nullptr`, with hexadecimal address `0x0`, then
I've found my bug.

Alternatively, most of you will have installed C++ and command-line
console tools that provide a debugger. On most people's systems, the
debugger tool is called `gdb`. This is the debugger provided with the
Gnu compiler suite (which includes `g++`). On many Mac OSX systems,
the debugger is instead provided as part of the LLVM compiler tools,
and the command is named `lldb`.

I'll work to show these commands' use in lecture and in lab, At a
minimum, you can use a debugger in a limited way to at least identify
the line of code where your segmentation fault is occurring. Below
shows an interaction that results from me testing my `llist` library
when it had a bug in my `deleteEnd` procedure. (I had forgotten to
check if the list only had one item in it.)

Here is that interaction:

    $ lldb test_llist
    (lldb) target create "test_llist"
    Current executable set to 'test_llist' (x86_64).
    (lldb) run 5 7 3
    Process 4586 launched: '/Users/jimfix/git/ReedCS2-S20/Lec03-3-examples/test_llist' (x86_64)
    Your list is [5, 7, 3].
    Enter a list command: delete end
    Done.
    Your list is [5, 7].
    Enter a list command: delete end
    Done.
    Your list is [5].
    Enter a list command: delete end
    Process 4586 stopped
    * thread #1: tid = 0x23d84, 
    0x0000000100007ac8 test_llist`llist::deleteEnd(list=0x00000001003000b0) + 56 at llist.cc:76,
    queue = 'com.apple.main-thread', stop reason = EXC_BAD_ACCESS (code=1, address=0x8)
    frame #0: 0x0000000100007ac8
    test_llist`llist::deleteEnd(list=0x00000001003000b0) + 56 at llist.cc:76
       73
       74      node* follower = list->first;
       75      node* leader = list->first->next;
    -> 76      while (leader->next != nullptr) {
       77        follower = leader;
       78        leader = leader->next;
       79      }
    (lldb) print leader
    (llist::node *) $0 = 0x0000000000000000
    (lldb) quit
    Quitting LLDB will kill one or more processes. Do you really want to proceed: [Y/n] Y
    $
     
In the above, I loaded the program into the debugger and ran it with
`run 5 7 3`. This is equivalent to just running the program in the
console with this command line

    $ ./test_llist 5 7 3

except it gets watched over by the debugger. After a few `delete end`
commands, making the list have only one element, my code then crashed
in the middle of `deleteEnd` at line 76 in `llist.cc`. I next printed
the value of the pointer `leader` and discovered that it was a null
pointer.

You can do similar work while developing your solutions. The key thing
that we did to enable this debugging was to compile the code with the
debug flag `-g`. This produces a different executable, one that's
filled with extra code information that both `gdb` and `lldb` can use
to give better feedback on your running program.

---

### Separate compilation: "header files" versus source files

Take a careful look through the starter code in the three files
`llist.cc`, `llist.hh`, and `test_llist.cc`. What you are seeing is a
more elaborate, and more careful, modularization of a program that
interacts with its user, manipulating a linked list data
structure. Rather than have one large program source file, I've
instead broken up the C++ code into the two files `llist.cc` and
`test_llist.cc`. I've also then written a *header file* `llist.hh` which
defines the linked list data structure and its operations. 

This header file is needed for several reasons, but overall because of
the way the C++ compiler works. It compiles each `.cc` file *on its
own*, and then combines that separately compiled code (the combining
of the code is called *linking*) into a single executable. I'll 
describe more how the header file is used, but the short of it is that 
this header file contains information about the `llist` structs and 
functions that are needed during the compilation of both `llist.cc`
and `test_llist.cc`.

The idea here is that the `llist.hh` and `llist.cc` files could be
combined with any program that needs a linked list, not just the tester
code. They are not specially written just for `test_llist` and can be
seen as a *library* that the tester relies on.

You'll notice, further, that my library code in `llist.cc` and
`llist.hh` define a *namespace* named `llist` that serves as the
prefix for all the type and function names it defines. So that means
that the test program defines a variable like so:

    llist::llist* theList;

to talk about a pointer to a `llist` struct named `theList`. And it
calls functions like so

    llist::insertAtFront(theList,what);

to invoke the ones named and defined in `llist.cc`.

The `llist::llist` and `llist::node` structs are defined separately in
the *header file* named `llist.hh` and the test program and the
implementation code each need to use those definitions, the files
`test_llist.cc` and `llist.cc` each have a line on the top reading

    #include "llist.hh"

This has the effect of asking the compiler to load in those definitions
when it is compiling that C++ source code. That is, when the compiler
is looking through the code in `llist.cc`, it needs to know the definitions 
that are provided in `llist.hh`, and so they are `#include`-ed at the top.
And when the compiler is reading the code for `test_llist.cc`, it needs
those definitions from `llist.hh` as well, and so they get stitched in
by the `#include` directive at the top of its file.

Finally, you'll notice that the `llist.hh` file has the three special
`#ifndef`, `#define`, and `#endif` directives surrounding the struct
and function declarations. This are needed due to some technical
idiosyncracies of how C++ compilation works, inherited from C. They are
used to make sure that no compilation `#include`s this information more
than once.

We'll continue to write C++ source code in this modular fashion. 


### Makefiles

Speaking of *separate compilation*, maybe now is the best time to introduce
a useful tool for performing compilation. I suppose it's possible, at this
point in the course, that you are getting tired of typing lines like

    g++ -std=c++11 -g -o pgm src1.cc src2.cc

or else tired of pressing the UP ARROW to find that long command that you've
been tired of typing. You might also wonder: *What if I was part of a much
larger project and it had **tons** of files that needed to be compiled?*
Your answer might be *Oh I bet they use a fancy IDE that does everything
for them.* and that may even be correct,  but that IDE has to be configured
for the project, and for many programmers this aspect of project construction
remains a mystery. (*IDE* means Integrated Development Environment, an
application that has editing, compiling, debugging, testing, building, etc.
wrapped up into one Swiss-army-knife like tool.)

There is a command-line tool that is used by lots of developers, called
`make`, and using it lays bare the things that an IDE has to manage, or
how an IDE gets configured. The tool is used,  typically,  two ways.
When it's set up right, and you are working on a program, you type
the command

    make

and the program you're working on gets built. Or, if you are working
on a larger project and it has several *targets* (i.e.  several
programs or libraries that can be built with the code), you might
instead type

    make test_llist

to specifically build that target executable.

Now, this may seem like some sort of magic, but there is some method
behind it, namely, `make` relies on a configuration file, called a
*make file* or *makefile*, that contains a specification of how each
target gets built. That file normally just sits in the same folder as
the source (though it doesn't actually have to) and is normally named
`Makefile` (though it doesn't have to be named that). A makefile is
just a text file that gives the set of commands that need to be issued
in order to construct the target programs of a project.

For example, for this source we could have the following makefile lines

    test_llist: test_llist.cc llist.hh llist.cc
            g++ -g -std=c++11 -o test_llist test_llist.cc llist.cc

These lines describe a target program: `test_llist`. It sits at the
far left of a line, immediately followed by a colon character
`test_llist:`. That is how you tell `make` that you're describing the
rules for constructing that target file. Then, on the next line (or
even *lines*) you have a *tabbed* line (a line that starts with an
actual `'\t'` character resulting from pressing the `[Tab]` key on the
keyboard) with the console command that produces that target.

Here is a different example that I could have used instead

    test_llist: test_llist.cc llist.cc llist.hh
            g++ -g -std=c++11 -c llist.cc
            g++ -g -std=c++11 -c test_llist.cc
            g++ -g -std=c++11 -o test_llist test_llist.o llist.o
	    rm test_llist.o
	    rm llist.o

Though we haven't talked about this much in class, it's possible to
produce intermediate compilation files, called *dot oh* files or
*object files*, or simply program *objects*.  These are the genuine
result of honest-to-goodness "separate compilation" (truth be told: my
section above avoided talking about separate compilation directly).
You can compile a program's C++ source file into its own object file
like so

    g++ -c src.cc

and this will produce its object file `src.o`. And then, once you've
got a bunch of object files, you can *link them together* with the
command

    g++ -o pgm src1.o src2.o src3.o etc.o

and this will create your executable `./pgm`.  And then, once that
program executable is built, these object files can be deleted (their
actual contents live, with all the other object files' contents,
within the contents of `pgm`). So it's okay to then type

    rm etc.o

and remove those files.

This all, then, is the full explanation for the longer makefile entry
I just showed you above. When someone types the command `make
test_llist`, then each of those command lines gets entered in
turn. (It's even a little better than that: if an error happens due to
some line's command failing, the subsequent lines won't get run.)

I haven't quite demystified the `makefile` entries completely.  It's
possible to also specify a targets *dependencies*. These are the files
that are needed to build the target, the files that the target
*depends on*. If someone were to change `llist.hh`, for example, the
`make` system knows that it needs to rebuild `test_llist` because of
that change.  So the line

    test_llist: test_llist.cc llist.hh llist.cc

tells `make` that `test_llist` relies on those three files for it to
be built. It also means that, if you change any one of those files,
that it needs to be rebuilt (and, of course, the line below tells it
how to build it). It knows this by the *time stamp* of each of the
files. If `test_llist` is older than `llist.cc`, for example, then
typing

    make test_llist

will get `make` re-make that target. If instead the target has the
latest time stamp of all those files, then typing `make test_llist`
leads to no action on `make`'s part:

    $ make test_llist
    make: 'test_llist' is up to date.

This, finally, is enough set-up to describe the structure of many
typical `Makefile`s. Here is a third way of describing a target,
as a series of entries:

    test_llist.o: test_llist.cc llist.hh
            g++ -g -std=c++11 -c test_llist.cc
	    
    llist.o: llist.cc llist.hh
            g++ -g -std=c++11 -c llist.cc

    test_llist: test_llist.o llist.o
            g++ -g -std=c++11 -o test_llist test_llist.o llist.o

What do these lines tell `make? These say that if a header file, or
the specific C++ source file that uses it, changes, then that object
file needs to be rebuilt. And it says that, should any of the object
files be rebuilt, than the executable that is made up of them needs to
be relinked with their latest versions. That way, if we change
`llist.hh`, both `.o` files need to be recompiled. But, if we just
change `llist.cc`, then only `llist.o` needs to be recompiled. Then,
in both scenarios, the `test_llist` executable needs to be
re-constructed with any rebuilt objects.

**Lastly**
Now, if you look at the `Makefile` I've actually provided, there are
a few other features (and in later projects I will show you even more).
It turns out, for example, if you type just `make` then the tool will
scan `Makefile` from the top and look for the first target entry.
That is treated as the *default target*.  So people often put a
first entry like

    all: test_llist

This will have no command lines underneath, and doesn't actually
describe the name of a target file. Nevertheless, if you type

    make all

or just `make` (with `all` being the first/default), then the
tool will do the work of building those three programs (because
after all we told `make` that the target `all` depends on them)
and looks for their target entries, builds each of them
accordingly.

And then, typically, at the bottom of a makefile people include
the lines

    clean:
           rm *.o *~ test_llist

so that they can type `make clean` to clear out all the cruft of
editing and compiling (the automatically saved `~` files, the object
files, the compiled executable) to have a fresh compilation space.

There are probably lots of resources and examples for `make` and
`Makefile` construction available on-line. The description and
examples above are from my own experience, and also from
the [tutorial](http://www.cs.colby.edu/maxwell/courses/tutorials/maketutor/)
by Bruce Maxwell at Colby College.

