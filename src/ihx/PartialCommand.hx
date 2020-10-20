/* ************************************************************************ */
/*                                                                          */
/*  Copyright (c) 2009-2020 Ian Martins (ianxm@jhu.edu)                     */
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
   put together a command string from keystrokes
**/
class PartialCommand
{
    /** current command string **/
    private var str :String;

    /** cursor position **/
    private var pos :Int;

    /** previously deleted text we may wish to yank back **/
    private var killedText :String;

    /** prompt to show **/
    public var prompt(null,default) :String;

    public function new(initialCommand="")
    {
        set(initialCommand);
        prompt = "";
        killedText = "";
    }

    /**
       add a character at the current position
    **/
    public function addChar(ch)
    {
        if( pos == str.length )
            str += ch;
        else
            str = str.substr(0, pos) + ch + str.substr(pos);
        cursorForward();
    }

    /**
       delete the character before the cursor
    **/
    public function backspace()
    {
        if( pos == 0 )
            return;
        str = str.substr(0, pos-1) + str.substr(pos);
        cursorBack();
    }

    /**
       delete the character under the cursor
    **/
    public function del()
    {
        if( pos == str.length )
            return;

        str = str.substr(0, pos) + str.substr(pos+1);
    }

    /**
       move the cursor foreward
    **/
    public function cursorForward()
    {
        pos += 1;
        pos = Std.int(Math.min(pos, str.length));
    }

    /**
       move the cursor back
    **/
    public function cursorBack()
    {
        pos -= 1;
        pos = Std.int(Math.max(pos, 0));
    }

    /**
       move the cursor to the front of the line
    **/
    public function home()
    {
        pos = 0;
    }

    /**
       move the cursor to the end of the line
    **/
    public function end()
    {
        pos = str.length;
    }

    /**
       set command to given string
    **/
    public function set(newStr)
    {
        str = newStr;
        pos = str.length;
    }

    /**
       get command
    **/
    public function toString()
    {
        return str;
    }

    /**
       get command to show on console.  draw twice to get the cursor in the right place.
    **/
    public function toConsole()
    {
        return "\r" + prompt + str + " " + "\r" + prompt + str.substr(0, pos);
    }

    /**
       get string to clear this command from the console
    **/
    public function clearString()
    {
        return "\r" + StringTools.rpad("", " ", str.length + prompt.length);
    }

    /**
       backspace to beginning of the command.  killed text can later be yanked back.
    **/
    public function killLeft()
    {
        killText(0, pos);
    }

    /**
       delete to end of the command.  killed text can later be yanked back.
    **/
    public function killRight()
    {
        killText(pos, str.length);
    }

    private function killText(startIndex, endIndex)
    {
        if(startIndex < pos && pos <= endIndex)
            pos = startIndex;

        killedText = str.substring(startIndex, endIndex);
        str = str.substring(0, startIndex) + str.substr(endIndex);
    }

    /**
       yank previously killed text
    **/
    public function yank()
    {
        str = str.substring(0, pos) + killedText + str.substr(pos);
        pos += killedText.length;
    }
}
