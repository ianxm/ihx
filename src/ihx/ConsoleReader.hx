/*
  Copyright (c) 2009-2010, Ian Martins (ianxm@jhu.edu)

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
*/

package ihx;

typedef CodeSet = {
    var arrow :Int;
    var up :Int;
    var down :Int;
    var right :Int;
    var left :Int;
    var backspace :Int;
    var ctrlc :Int;
    var enter :Int;
}

/**
   read a command from the console.  handle arrow keys.
**/
class ConsoleReader
{
    public var cmd(default,null) :PartialCommand;
    private var code :Int;
    private var history :History;
    private var codeSet :CodeSet;

    public static function main()
    {
        var cr = new ConsoleReader();
        var cmdStr = cr.readLine();
        neko.Lib.println("\n" + cmdStr);
    }

    public function new()
    {
        code = 0;
        cmd = new PartialCommand();
        history = new History();
        if( neko.Sys.systemName() == "Windows" )
            codeSet = {arrow: 224, up: 72, down: 80, right: 77, left: 75, 
                       backspace: 8, ctrlc: 3, enter: 13};
        else
            codeSet = {arrow: 27, up: 65, down: 66, right: 67, left: 68,
                       backspace: 127, ctrlc: 3, enter: 13};
    }

    // get a command from the console
    public function readLine()
    {
        cmd.set("");
        while( true )
        {
            code = neko.io.File.getChar(false);
            if( code == codeSet.arrow ) // arrow keys
            {
                if( neko.Sys.systemName() != "Windows" )
                    neko.io.File.getChar(false); // burn extra char
                code = neko.io.File.getChar(false);
                switch( code )
                {
                case codeSet.up:    { clear(cmd); cmd.set(history.prev()); }
                case codeSet.down:  { clear(cmd); cmd.set(history.next()); }
                case codeSet.right: cmd.cursorForward();
                case codeSet.left:  cmd.cursorBack();
                }
            }
            else
            {
                switch( code )
                {
                case codeSet.ctrlc: { neko.Lib.println(""); neko.Sys.exit(1); }
                case codeSet.enter: { neko.Lib.println(""); history.add(cmd.toString()); return cmd.toString(); }
                    //case 126: cmd.del(); // del shares code with tilde?
                case codeSet.backspace: cmd.backspace();
                default: cmd.addChar(String.fromCharCode(code));
                }
            }
            neko.Lib.print(cmd.toConsole());
        }
        return "";
    }

    public function clear(len)
    {
        neko.Lib.print(cmd.clearString());
    }
}
