ihx - the interactive haxe shell
================================

overview
--------

ihx is an interactive haxe shell.  each statement entered is run
through the haxe compiler and neko interpreter, and the return value
is displayed.  while the system's standard haxe and neko executables
are being used, there are some differences from standard haxe
programming.

- only one var can be declared per line (no 'var a,b,c;')

- omitting the semicolon at the end of a statement prints the return
  value to the console

- multiple statements on a line are allowed, but the trailing
  semicolon is required (no 'var a=1; var b=2')

- to enter a multiline statement, end each incomplete line with '\'

- comments are not allowed


neko in the background
----------------------

the haxe compiler and neko vm can't be run with partial scripts so
each line on input compiles and runs a script that is built up in
memory during the ihx session.  this means that every valid statement
in a session is re-run in order to evaluate each new statement.  while
this works (and is barely noticeable since the haxe compiler is so
fast) it may result in unexpected behaviors.

statements with side effects will be re-run after every statement.
here is an example to illustrate:

     >> var fout = sys.io.File.append("file.txt");

     >> fout.writeString("hello\n");

     >> fin.close();

at this point, the file contains two `hello` lines.  one was written
after the second statement and the other after the third statement.
if the file is opened with `write` instead of `append`, it will clear
the file each time neko evaluates the script, and will result in a
single `hello`.

ihx does some special handling for variable declarations, so in some
situations it is possible to change a variable's type by redeclaring
it.  for example, this will work:

    >> var a = 1
    1

    >> a = 1.2
    error: Float should be Int

    >> var a :Float = 1.2
    1.2

but this won't work:

    >> var a = 1
    1

    >> a = "car"
    error: Float should be Int

    >> var a :String = "car"
    error: Int should be String

the problem here is that changing `a`'s type broke the first
statement that assigned it to `1`.

the full script can be dumped to the screen with the `print` command.
it can be cleared with the `clear` command.


installation
------------

ihx can be run through haxelib with the command:

    haxelib run ihx

alternatively, an executable can be obtained either through the
project repository or by making it from the "run.n" file included in
the haxelib distribution.


usage
-----

the ihx shell accepts the following commands:

- dir            list all currently defined variables
- addlib [name]  add a haxelib library to the search path
- rmlib  [name]  remove a haxelib library from the search path
- libs           list haxelib libraries that have been added
- clear          delete all variables from the current session
- print          dump the temp neko program to the console
- help           print this message
- exit           close this session
- quit           close this session

the above commands will be processed by ihx, all other input will be
passed to the haxe compiler.  if output is not suppressed with a
trailing semicolon, the return value will be printed to the console.

the standard prompt of `>> ` is displayed when ihx is waiting for
input.  the `.. ` prompt indicates that the last line of input was an
incomplete statement, and ihx is waiting for the rest.

haxelib libraries can be made accessible with the `addlib` command.
`clear` does not remove libs from the session.


example
-------

the following is an example of an ihx session:

    haxe interactive shell v0.2.1
    type "help" for help
    >> var a=1
    1

    >> var b = 2;                       <-- suppress output with trailing semicolon

    >> var c=a+b
    3

    >> Math.sin(c)
    0.1411200081

    >> str = 'this is a string'
    this is a string

    >> str2='multiline\nstring'
    multiline
    string

    >> str3='multiline ' \              <-- line continuation with '\'
    .. + 'command'
    multiline command

    >> dir                              <-- get list of variables in the session
    vars: a, b, c, str, str2, str3

    >> var arr = [1,4,2,5,1]
    [1,4,2,5,1]

    >> arr.sort(Reflect.compare)
    null

    >> arr
    [1,1,2,4,5]

    >> var timestwo = function(ii) { return ii*2; }
    #function:1

    >> using Lambda;                    <-- 'using' and 'import' work as expected

    >> arr.map(timestwo)
    {2, 2, 4, 8, 10}

    >> var nameRe = ~/name: ([a-z]+)/;

    >> var nameRe.match("name: charlie")
    true

    >> nameRe.matched(1)
    charlie

    >> var d = { one: 1, two: "two" }   <-- anonymous objects work as expected
    { one => 1, two => two }

    >> haxe.Json.stringify(d)           <-- standard library call without import
    {"one":1,"two","two"}

    >> enum Color {\                    <-- enums and typedefs work as expected
    .. RED;\
    .. BLACK;\
    .. }

    >> typedef Car = { color:Color, name:String }

    >> var car = { color: RED, name: "gus" }
    { name => gus, color => RED }

    >> addlib hxSet                     <-- add a haxelib library to the session
    added: hxSet

    >> libs                             <-- list haxelib libraries that have been added
    libs: hxSet

    >> var s = new Set<Int>();

    >> s.union([1,2,3,2,1,5,4,1])
    5

    >> s.list()
    {4, 5, 3, 2, 1}

    >> quit


