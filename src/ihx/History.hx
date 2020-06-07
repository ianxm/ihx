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

/**
   remember the past commands.
**/
class History
{
    private var commands :Array<String>;
    private var maxCommands :Int;
    private var saveFile :String;
    private var pos :Int;

    public function new(maxCommands=-1, saveFile="")
    {
        // The empty string will always be in the history at index 0,
        // and should not count against the command history limit.
        this.maxCommands = maxCommands + 1;
        this.saveFile = saveFile;
        if ( saveFile.length > 0 )
        {
            load();
        }
        else
        {
            commands = [""];
            pos = 1;
        }
        // Attempt to save the history so the user will be warned in advance
        // if it fails.
        save();

        pos = commands.length;
    }

    private function load()
    {
        try
        {
            commands = sys.io.File.getContent(saveFile).split("\n");
            commands.insert(0, "");
        }
        catch ( err: Dynamic ) {
            Sys.println('Warning! Failed to read history from $saveFile: $err');
            commands = [""];
        }
        if ( isFull() )
        {
            commands = commands.splice(0, commands.length - maxCommands);
        }
    }

    public function save()
    {
        if ( saveFile.length > 0 )
        {
            try
            {
                // Save the command history without the empty string at index 0.
                sys.io.File.saveContent(saveFile, commands.slice(1).join("\n"));
            }
            catch ( err: Dynamic )
            {
                Sys.println('Warning! Failed to write history to $saveFile: $err');

                // Don't try saving the history more than once
                saveFile = "";
            }
        }
    }

    private function isFull() {
        return maxCommands > 0 && commands.length > maxCommands;
    }

    public function add(cmd)
    {
        commands.push(cmd);
        if ( isFull() )
        {
            // Drop the oldest command to save the newest one
            commands.shift();
        }
        pos = commands.length;
    }

    public function next()
    {
        pos += 1;
        return commands[pos % commands.length];
    }

    public function prev()
    {
        pos -= 1;
        if( pos < 0 )
            pos += commands.length;
        return commands[pos % commands.length];
    }
}
