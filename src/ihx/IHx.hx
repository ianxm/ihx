/* ************************************************************************ */
/*                                                                          */
/*  Copyright (c) 2009-2013 Ian Martins (ianxm@jhu.edu)                     */
/*                                                                          */
/* This library is free software; you can redistribute it and/or            */
/* modify it under the terms of the GNU Lesser General Public               */
/* License as published by the Free Software Foundation; either             */
/* version 3.0 of the License, or (at your option) any later version.       */
/*                                                                          */
/* This library is distributed in the hope that it will be useful,          */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of           */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        */
/* Lesser General Public License or the LICENSE file for more details.      */
/*                                                                          */
/* ************************************************************************ */

package ihx;

import sys.io.FileInput;
import neko.Lib;
import sys.FileSystem;
import ihx.CmdProcessor;

/**
   ihx is an interactive session for haxe programming.  It builds
   compiles and runs input as a neko program in the background.
**/
class IHx
{
    private static var VERSION = "0.3.6";

    /** the source for commands **/
    private var console :ConsoleReader;

    /** 
       whether to run minimal interpretor, e.g. Codi.
       codi allows running interpretors in Vim but won't 
       work with ihx more elaborated interpretor, so ihx can be 
       started with -codi option
     */
    private var useCodi :Bool;

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
        console = new ConsoleReader();
        useCodi = false;
    }

    /**
       get commands from the console, process them, display output
       handle ihx commands, get haxe statement (can be multiline), parse it, pass to execution method
    **/
    public function run()
    {
        var debug = false;
        var paths:Set<String> = [];
        var libs:Set<String> = [];
        var defines:Set<String> = [];

        var args = Sys.args();
        if (args.length > 0 && Sys.systemName() == "Windows") args.shift();
        while( args.length > 0 )
        {
            var arg = args.shift();
            switch ( arg ) {
                case "-debug":
                    debug = true;
                case "-cp":
                    paths.add(args.shift());
                case "-lib":
                    libs.add(args.shift());
                case "-D":
                    defines.add(args.shift());
                case cwd if (FileSystem.exists(cwd)):
                    Sys.setCwd(cwd);
                case "-codi":
                    useCodi = true;
                case _:
                    Lib.println('Unknown argument "$arg"');
                    Lib.println("Usage: neko ihx [-debug] [-cp /class/path/] [-lib ihx:0.3.0] [-D some_define] [-codi] [workingdir]");
                    Sys.exit(1);
            }
        }

        Lib.println("haxe interactive shell v" + VERSION);
        Lib.println("type \"help\" for help");
        if (useCodi) Lib.println("Launched with -codi");

        var processor = new CmdProcessor(debug,paths,libs,defines);

        while( true )
        {
            // initial prompt
            console.cmd.prompt = ">> ";
            Lib.print(">> ");

            if (!useCodi) 
            {
                while (true)
                {
                    try
                    {
                        var ret = processor.process(console.readLine());
                        if( ret != null )
                            Lib.println(ret+"\n");
                    }
                    catch (ex:CmdError)
                    {
                        switch (ex)
                        {
                        case IncompleteStatement:
                            {
                                console.cmd.prompt = ".. "; // continue prompt
                                Lib.print(".. ");
                                continue;
                            }
                        case InvalidStatement(msg): Lib.println(msg);
                        }
                    }

                    // restart after an error or completed command
                    console.cmd.prompt = ">> ";
                    Lib.print(">> ");
                }
            }
            else 
            {
                // using codi: vim with the codi plugin requires
                // a more conventional interpreter, hence following 
                // implementation (launched with "haxelib run ihx -codi") 
                while (true) {
                    Lib.print(">> ");
                    var line = Sys.stdin().readLine();
                    Lib.println(line);
                    if (line == "exit") break;
                    else if (StringTools.trim(line) == "") continue;
                    else {
                        try {
                            var ret = processor.process(line);
                            if (ret != null) Lib.println(ret + "\n");
                        }
                        catch (ex:CmdError) { Lib.println("Bollocks"); }
                    }
                }
            }
        }
    }
}
