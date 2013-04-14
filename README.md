ihx - the interactive haxe shell
================================

overview
--------

ihx is an interactive neko shell.  each statement entered is run
through the haxe compiler and neko interpreter, and the return value
is displayed.  while the system's standard haxe and neko executables
are being used, there are some differences.

- only one var can be declared per line (no 'var a,b,c;')

- omitting the semicolon at the end of a statement prints the return
  value to the console

- to enter a multiline statement, end each incomplete line with '\'

- comments are not allowed

- to change a variable's type, redeclare it

- statements with side effects (such as appending to a file) will not
  work as expected since all valid statements in a session are
  re-executed in order to evaluate each statement.

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

- dir      list all currently defined variables
- builtins list all builtin classes
- clear    clear all variables and reset the session
- print    print the temp neko program source
- help     print this message
- exit     close this session
- quit     close this session

the above commands will be processed by ihx, all other input will be
passed to the haxe compiler.  if output is not suppressed with a
trailing semicolon, the return value will be printed to stdout.

the standard prompt of '>> ' is displayed when ihx is waiting for
input.  the '.. ' prompt indicates that the last line of input was an
incomplete statement, and ihx is waiting for the rest.


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
    a, b, c, str, str2, str3

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

    >> quit


