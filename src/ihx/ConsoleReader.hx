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

/**
	read a command from the console.  handle arrow keys.
 **/
class ConsoleReader
{
  public var cmd(default,null) : PartialCommand;
  private var code : Int;
  private var history : History;

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
  }

  // get a command from the console
  public function readLine()
  {
    cmd.set("");
    while( true )
    {
      code = neko.io.File.getChar(false);
      if( code == 27 ) // arrow keys
      {
	neko.io.File.getChar(false);
	code = neko.io.File.getChar(false);
	switch( code )
	{
	case 65: { clear(cmd); cmd.set(history.prev()); }
	case 66: { clear(cmd); cmd.set(history.next()); }
	case 67: cmd.cursorForward();
	case 68: cmd.cursorBack();
	}
      }
      else
      {
	switch( code )
	{
	case 3: { neko.Lib.println(""); neko.Sys.exit(1); } // ctrl-c
	case 13: { neko.Lib.println(""); history.add(cmd.toString()); return cmd.toString(); } // enter
	  //case 126: cmd.del(); // del shares code with tilde?
	case 127: cmd.backspace();
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