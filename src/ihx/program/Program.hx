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

package ihx.program;

import haxe.ds.StringMap;

using StringTools;
using Lambda;

class Program
{
    public static var separator = "~~~~~~~~~~~";

    // TODO should prevent network calls?

    private var defs     :StringMap<Def>;                      // typedef/enum declarations
    private var vars     :StringMap<Var>;                      // variable declarations
    private var imports  :List<Statement>;                     // import statements
    private var commands :List<Statement>;                     // commands
    private var cleanUp  :List<Statement>;                     // close files, etc?
    private var suppressOutput :Bool;                          // if false, print the result of the last command
    private var tmpFileSuffix :String;                         // unique suffix appended to temp filenames

    private static var varRegex        :EReg = ~/var \s*([a-zA-Z][a-zA-Z0-9_]*).*/;
    private static var varTypeRegex    :EReg = ~/var \s*([a-zA-Z][a-zA-Z0-9_]*)\s*:\s*([a-zA-Z][a-zA-Z0-9<>_\- ,]+).*/;
    private static var varValRegex     :EReg = ~/var \s*([a-zA-Z][a-zA-Z0-9_]*)\s*=\s*(.*)/;
    private static var varTypeValRegex :EReg = ~/var \s*([a-zA-Z][a-zA-Z0-9_]*)\s*:\s*([a-zA-Z][a-zA-Z0-9<>_\- ,]+)\s*=\s*(.*)/;

    private static var enumRegex    :EReg = ~/enum \s*([a-zA-Z][a-zA-Z0-9_]*)\s*({[^}]+})/;
    private static var typedefRegex :EReg = ~/typedef \s*([a-zA-Z][a-zA-Z0-9_]*)\s*=\s*({[^}]+})/;

    public function new(tmpFileSuffix :String)
    {
        this.tmpFileSuffix = tmpFileSuffix;
        defs     = new StringMap<Def>();
        vars     = new StringMap<Var>();
        imports  = new List<Statement>();
        commands = new List<Statement>();
        cleanUp  = new List<Statement>();
    }

    /**
       add a new statement to the program
     */
    public function addStatement(stmt :String)
    {
        if( stmt.startsWith("import ") || stmt.startsWith("using "))
            imports.add(new Statement(stmt, true));
        else if( enumRegex.match(stmt) )
            defs.set(enumRegex.matched(1), new Def(enumRegex.matched(1), enumRegex.matched(2), "enum"));
        else if( typedefRegex.match(stmt) )
            defs.set(typedefRegex.matched(1), new Def(typedefRegex.matched(1), typedefRegex.matched(2), "typedef"));
        else if( stmt.startsWith("var ") )                  // only allow one var per line, no 'var a,b,c;'
        {
            if( varTypeValRegex.match(stmt) )               // var name :Type = val
            {
                vars.set(varTypeValRegex.matched(1), new Var(varTypeValRegex.matched(1), varTypeValRegex.matched(2)));
                commands.add(new Statement(varTypeValRegex.matched(1)+" = "+varTypeValRegex.matched(3)));
            }
            else if( varTypeRegex.match(stmt) )             // var name :Type
            {
                vars.set(varTypeRegex.matched(1), new Var(varTypeRegex.matched(1), varTypeRegex.matched(2)));
            }
            else if( varValRegex.match(stmt) )              // var name = val
            {
                vars.set(varValRegex.matched(1), new Var(varValRegex.matched(1)));
                commands.add(new Statement(varValRegex.matched(1)+" = "+varValRegex.matched(2)));
            }
            else if( varRegex.match(stmt) )                 // var name
            {
                vars.set(varRegex.matched(1), new Var(varRegex.matched(1)));
            }
        }
        else
        {
            commands.add(new Statement(stmt));
        }
    }

    /**
       no error when the last command was evaluated.  include it in the program.
     */
    public function acceptLastCmd(val :Bool)
    {
        if( val )
        {
            for( ii in defs.keys() )
                defs.get(ii).isNew = false;
            for( ii in vars.keys() )
                vars.get(ii).isNew = false;
            imports.iter(  function(ii) ii.isNew = false );
            commands.iter( function(ii) ii.isNew = false );
        }
        else
        {
            for( ii in defs.keys() )
                if( defs.get(ii).isNew )
                    defs.remove(ii);
            for( ii in vars.keys() )
                if( vars.get(ii).isNew )
                    vars.remove(ii);
            imports  = imports.filter(  function(ii) return !ii.isNew );
            commands = commands.filter( function(ii) return !ii.isNew );
        }
    }

    /**
       get list of declared variables
     */
    public function getVars() :List<String>
    {
        var ret = new Array<String>();
        for( ii in vars.keys() )
            ret.push(ii);
        ret.sort( Reflect.compare );
        return ret.list();
    }

    /**
       get the program as a string
     */
    public function getProgram( ?includeHelpers=true )
    {
        var sb = new StringBuf();

        if( includeHelpers ) {
            sb.add("import haxe.macro.Expr;\n"); 
            sb.add("import haxe.macro.Context;\n"); 
        }
        sb.add("#if !macro \n");                            // separate macro code from runtime code to avoid "You cannot use @:build inside a macro" error
        sb.add("import neko.Lib;\n");                       // imports
        for( ii in imports )
            sb.add(ii.toString() +"\n");

        sb.add("\n");

        for( ii in defs )                                   // typedefs and enums
            sb.add(ii.toString() +"\n");

        sb.add("\n");

        sb.add("class IhxProgram_"+tmpFileSuffix+" {\n");
        sb.add("    public static function main() {\n");

        for( ii in vars.keys() )                            // vars
            sb.add("        "+ vars.get(ii).toString() +"\n");

        sb.add("\n");

        for( ii in commands )                               // old commands
        {
            if( ii.isNew )
                sb.add("        Lib.println('"+separator+"');\n");
            sb.add("        "+ ii.toString() +"\n");
        }

        sb.add("    }\n");
        sb.add("}\n");
        sb.add("#end \n");                            // separate macro code from runtime code to avoid "You cannot use @:build inside a macro" error

        if( includeHelpers ) sb.add(haxe.Resource.getString("formatterclass"));
        return sb.toString();
    }
}
