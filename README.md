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

- to enter a multiline statement, end each incomplete line with '\'

- comments are not allowed

- to change a variable's type, redeclare it.  for example:

    >> var a = 1
    1
    
    >> a = 1.2
    error: Float should be Int

    >> var a :Float = 1.2
    1.2

- statements with side effects (such as appending to a file) will not
  work as expected since all valid statements in a session are
  re-executed when each new statement is evaluated.


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

    haxe interactive shell v0.2.0
    type "help" for help
    >> var a=1
    1

    >> var b = 2;

    >> var c=a+b
    3

    >> Math.sin(c)
    0.1411200081

    >> str = 'this is a string'
    this is a string

    >> str2='multiline\nstring'
    multiline
    string

    >> str3='multiline ' \
    .. + 'command'
    multiline command

    >> dir
    vars: a, b, c, str, str2, str3

    >> var arr = [1,4,2,5,1]
    [1,4,2,5,1]

    >> arr.sort(Reflect.compare)
    null

    >> arr
    [1,1,2,4,5]

    >> timestwo = function(ii) { return ii*2; }
    #function:1

    >> using Lambda;

    >> arr.map(timestwo)
    {2, 2, 4, 8, 10}

    >> var nameRe = ~/name: ([a-z]+)/;

    >> var nameRe.match("name: charlie")
    true

    >> nameRe.matched(1)
    charlie

    >> var d = { one: 1, two: "two" }
    { one => 1, two => two }

    >> haxe.Json.stringify(d)
    {"one":1,"two","two"}

    >> enum Color {\
    .. RED;\
    .. BLACK;\
    .. }

    >> typedef Car = { color:Color, name:String }

    >> var car = { color: RED, name: "gus" }
    { name => gus, color => RED }

    >> addlib hxSet
    added: hxSet

    >> libs
    libs: hxSet

    >> var s = new Set<Int>();

    >> s.union([1,2,3,2,1,5,4,1])
    5

    >> s.list()
    {4, 5, 3, 2, 1}

    >> quit


