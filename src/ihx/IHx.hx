/*
 Copyright (c) 2009, Ian Martins (ianxm@jhu.edu)

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

import neko.io.FileInput;
import neko.Lib;
import ihx.CmdProcessor;

/**
	IHx is an interactive session for haxe programming.  The code is basically a command line
	interface for Hscript.
 **/
class IHx
{
  private static var VERSION = "0.0.1";

  /** the source for commands **/
  private var stdin : FileInput;

  /**
	start the interpreter
   **/
  public static function main()
  {
    var interpreter = new IHx();
    interpreter.run();
  }

  /**
	populate the builtin variable lists, instantiate the hscript engine
   **/
  public function new()
  {
    stdin = neko.io.File.stdin();
  }
  
  /**
	get commands from stdin, process them, display output
	handle ihx commands, get haxe statement (can be multiline), parse it, pass to execution method
   **/
  public function run()
  {
    Lib.println("haXe interactive shell v" + VERSION);
    Lib.println("type \"help\" for help");

    var processor = new CmdProcessor();

    while( true )
    {
      // initial prompt
      Lib.print(">> ");

      while (true)
      {
	try
	{
	  var ret = processor.process(stdin.readLine());
	  if( ret != null )
	    Lib.println(ret);
	}
	catch (ex:CmdError)
	{
	  if(Type.enumConstructor(ex) == "IncompleteStatement")
	  {
	    Lib.print(".. "); // continue prompt
	    continue;
	  }
	  else if (Type.enumConstructor(ex) == "InvalidStatement")
	  {
	    Lib.println("Syntax error. " + ex);
	  }
	  else
	    Lib.println("Execution error. " + Type.enumParameters(ex)[0]);
	}

	// restart after an error or completed command
	Lib.print(">> ");
      }
    }
  }
}