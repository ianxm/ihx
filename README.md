ihx - the interactive haxe shell
================================

overview
--------

ihx is an interactive haxe shell.  each statement entered is run
through the haxe compiler, then possibly an interpreter, then the
return value is displayed.


installation
------------

ihx can be installed and run through haxelib with the commands:

    haxelib install ihx

    haxelib run ihx

alternatively, an executable can be obtained either through the
project repository or by making it from the "run.n" file included in
the haxelib distribution.  ihx accepts the following command line
options for specifying to which target to build:

- `-neko`             target neko vm
- `-hl`               target hashlink vm
- `-python`           target python3
- `-python3`          target python3
- `-js`               target javascript

if no target is specified, ihx will use haxe's interp mode, where the
haxe compiler interprets the code.

ihx also accepts these command line options:

- `-debug`            enable debug mode
- `-cp [path]`        add `path` to the classpath
- `-lib [name]`       add a haxelib library
- `-D [name]`         add a define
- `-codi`             use simplified console reader for use with codi
- `-hist-file [name]` save command history to this file (default don't save history)
- `-hist-max [num]`   save up to `num` commands in the history file (default 50)


differences from standard haxe
------------------------------

while the system's standard haxe/neko/etc executables are being used,
not all valid haxe statements will work in ihx.

- only one var can be declared per line (no `var a,b,c;`)

- omitting the semicolon at the end of a statement prints the return
  value to the console (but the semicolon is required if the statement
  has return type `Void`)

- multiple statements on a line are allowed, but the trailing
  semicolon is required (no `var a=1; var b=2`)

- to enter a multiline statement, end each incomplete line with '\'

- comments are not allowed


side effects
------------

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
    Int : 1

    >> a = 1.2
    error: Float should be Int

    >> var a :Float = 1.2
    Float : 1.2

but this won't work:

    >> var a = 1
    Int : 1

    >> a = "car"
    error: String should be Int

    >> var a :String = "car"
    error: Int should be String

the problem here is that changing `a`'s type broke the first
statement that assigned it to `1`.

the full script can be dumped to the screen with the `print` command.
it can be cleared with the `clear` command.


usage
-----

in addition to haxe statements, the ihx shell accepts the following
commands:

- `dir`               list all currently defined variables
- `addpath [name]`    add a dir to the classpath
- `rmpath  [name]`    remove a dir from the classpath
- `path`              list the dirs in the classpath
- `addlib [name]`     add a haxelib library to the search path
- `rmlib  [name]`     remove a haxelib library from the search path
- `libs`              list haxelib libraries that have been added
- `adddefine [name]`  add a define (same as "-D name")
- `rmdefine  [name]`  remove a define
- `defines`           list defines that have been added
- `debug`             toggle haxe debug mode
- `clear`             delete all variables from the current session
- `print`             dump the temp neko program to the console
- `help`              print this message
- `exit`              close this session
- `quit`              close this session

the above commands will be processed by ihx, all other input will be
passed to the haxe compiler.  if output is not suppressed with a
trailing semicolon, the return value will be printed to the console.

the standard prompt of `>> ` is displayed when ihx is waiting for
input.  the `.. ` prompt indicates that the last line of input was an
incomplete statement, and ihx is waiting for the rest.

haxelib libraries can be made accessible with the `addlib` command.
`clear` does not remove libs from the session.


example session
---------------

the following is an example of an ihx session:

    $ haxelib run ihx

    haxe interactive shell v0.4.2
    running in interp mode
    type "help" for help
    >> var a=1
    Int : 1

    >> var b = 2;                        <-- suppress output with trailing semicolon

    >> var c=a+b
    Int : 3

    >> Math.sin(c)
    Float : 0.141120008059867214

    >> var str = 'this is a string'
    String : this is a string

    >> var str2='multi-line\nstring'

    String : multi-line
    string

    >> var str3='multi-line ' \          <-- line continuation with '\'
    .. + 'command'
    String : multi-line command

    >> dir                               <-- get list of variables in the session
    vars: a, b, c, str, str2, str3

    >> var arr = [1,4,2,5,1]
    Array<Int> : [1,4,2,5,1]

    >> arr.sort(Reflect.compare);        <-- must suppress output because sort's return type is Void

    >> arr
    Array<Int> : [1,1,2,4,5]

    >> var timestwo = function(ii) { return ii*2; }
    Int -> Int : #fun
    >> using Lambda;                     <-- 'using' and 'import' work as expected

    >> arr.map(timestwo)
    Array<Int> : [2,2,4,8,10]

    >> var nameRe = ~/name: ([a-z]+)/;

    >> nameRe.match("name: charlie")
    Bool : true

    >> nameRe.matched(1)
    String : charlie

    >> var d = { one: 1, two: "two" }    <-- anonymous objects work as expected
    { var two : String; var one : Int; } : {one: 1, two: two}

    >> haxe.Json.stringify(d)            <-- standard library call without import
    String : {"one":1,"two":"two"}

    >> enum Color {\                     <-- enums and typedefs work as expected
    .. RED;\
    .. BLACK;\
    .. }

    >> typedef Car = { color :Color, name :String }

    >> var car = { color: RED, name: "gus" }
    { var name : String; var color : IhxProgram_5836.Color; } : {name: gus, color: RED}

    >> addlib random                     <-- add a haxelib library to the session
    added lib: random

    >> libs                              <-- list haxelib libraries that have been added
    libs: random

    >> var s = Random.int(0, 100)
    Int : 89

    >> quit                              <-- or 'exit' or Ctrl-C or Ctrl-D


errors
------

<dl>
  <dt>`Accessing this field requires a system platform`</dt>
  <dd>when targeting javascript, be sure to add the "hxnekojs" library.</dd>
  <dt>`Cannot use Void as a value`</dt>
  <dd>include the semicolon at the end of any line that doesn't return a value.</dd>
</dl>
