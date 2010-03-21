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
	remember the past commands.
 **/
class History
{
  private var commands : Array<String>;
  private var pos : Int;

  public function new()
  {
    commands = [""];
    pos = 0;
  }

  public function add(cmd)
  {
    commands.push(cmd);
    pos = commands.length;
  }

  public function next()
  {
    if( pos == commands.length )
      return "";
    pos += 1;
    return commands[pos];
  }

  public function prev()
  {
    if( pos > 0 )
      pos -= 1;
    return commands[pos];
  }
}