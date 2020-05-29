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
            try
            {
                commands = sys.io.File.getContent(saveFile).split("\n");
                commands.insert(0, "");
            }
            catch ( err: Dynamic ) {
                commands = [""];
            }
            if ( maxCommands > 0 && commands.length > maxCommands )
            {
                commands = commands.splice(0, commands.length - maxCommands);
            }
            pos = commands.length;
        }
        else
        {
            commands = [""];
            pos = 1;
        }
    }

    public function add(cmd)
    {
        commands.push(cmd);
        if ( maxCommands > 0 && commands.length > maxCommands ) 
        {
            commands.shift();
        }
        if ( saveFile.length > 0 )
        {
            // Save the command history without the empty string at index 0.
            sys.io.File.saveContent(saveFile, commands.slice(1).join("\n"));
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
