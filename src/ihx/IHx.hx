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
import haxe.io.Output;
import sys.FileSystem;
import ihx.CmdProcessor;

/**
   ihx is an interactive session for haxe programming.  It builds
   compiles and runs input as a neko program in the background.
**/
class IHx
{
    private static var VERSION = "0.3.7";

    /** the source for commands **/
    private var console :ConsoleReader;

    /** stdout stream */
    private var stdout :Output = Sys.stdout();

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

    public function new()
    {
        useCodi = false;
    }

    private function quit()
    {
        console.saveHistory();
        Sys.exit(0);
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

        var maxHistory = 50;
        var historyFile = "";

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
                case "-hist-file":
                    historyFile = args.shift();
                case "-hist-max":
                    maxHistory = Std.parseInt(args.shift());
                case _:
                    stdout.writeString('Unknown argument "$arg"\n');
                    stdout.writeString("Usage: neko ihx [-debug] [-cp /class/path/] [-lib ihx:0.3.0] [-D some_define] [-codi] [-hist-file file] [-hist-max max] [workingdir]\n");
                    Sys.exit(1);
            }
        }
        console = new ConsoleReader(maxHistory, historyFile);

        stdout.writeString("haxe interactive shell v" + VERSION + "\n");
        stdout.writeString("type \"help\" for help\n");
        if (useCodi) stdout.writeString("Launched with -codi\n");

        var processor = new CmdProcessor(quit,debug,paths,libs,defines);

        while( true )
        {
            // initial prompt
            console.cmd.prompt = ">> ";
            stdout.writeString(">> ");

            if (!useCodi)
            {
                while (true)
                {
                    try
                    {
                        var ret = processor.process(console.readLine());
                        if( ret != null )
                            stdout.writeString(ret+"\n");
                    }
                    catch (ex:CmdError)
                    {
                        switch (ex)
                        {
                        case IncompleteStatement:
                            {
                                console.cmd.prompt = ".. "; // continue prompt
                                stdout.writeString(".. ");
                                continue;
                            }
                        case InvalidStatement(msg): stdout.writeString(msg + "\n");
                        }
                    }

                    // restart after an error or completed command
                    console.cmd.prompt = ">> ";
                    stdout.writeString(">> ");
                }
            }
            else
            {
                // using codi: vim with the codi plugin requires
                // a more conventional interpreter, hence following
                // implementation (launched with "haxelib run ihx -codi")
                while (true) {
                    stdout.writeString(">> ");
                    var line = Sys.stdin().readLine();
                    stdout.writeString(line + "\n");
                    if (line == "exit") break;
                    else if (StringTools.trim(line) == "") continue;
                    else {
                        try {
                            var ret = processor.process(line);
                            if (ret != null) stdout.writeString(ret + "\n");
                        }
                        catch (ex:CmdError) { stdout.writeString("Bollocks\n"); }
                    }
                }
            }
        }
    }
}
