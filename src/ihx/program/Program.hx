package ihx.program;

using StringTools;
using Lambda;

class Program
{
    public static var separator = "~~~~~~~~~~~";

    // TODO should prevent network calls?
    // TODO could handle typedefs/enums like vars, would need a section above main function

    private var vars     :Hash<Var>;                           // variable declarations
    private var imports  :List<Statement>;                     // import statements
    private var commands :List<Statement>;                     // commands
    private var cleanUp  :List<Statement>;                     // close files, etc?
    private var suppressOutput :Bool;                          // if false, print the result of the last command

    private static var getVarRegex        :EReg = ~/\s*([a-zA-Z][a-zA-Z0-9_]*).*/;
    private static var getVarTypeRegex    :EReg = ~/\s*([a-zA-Z][a-zA-Z0-9_]*)\s*:\s*([a-zA-Z][a-zA-Z0-9<>_\- ]+).*/;
    private static var getVarValRegex     :EReg = ~/\s*([a-zA-Z][a-zA-Z0-9_]*)\s*=\s*(.*)/;
    private static var getVarTypeValRegex :EReg = ~/\s*([a-zA-Z][a-zA-Z0-9_]*)\s*:\s*([a-zA-Z][a-zA-Z0-9<>_\- ]+)\s*=\s*(.*)/;

    public function new()
    {
        vars     = new Hash<Var>();
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
        {
            imports.add(new Statement(stmt, true));
        }
        else if( stmt.startsWith("var ") ) // only allow one var per line, no 'var a,b,c;'
        {
            stmt = stmt.substr(4);
            if( getVarTypeValRegex.match(stmt) )
            {
                vars.set(getVarTypeValRegex.matched(1), new Var(getVarTypeValRegex.matched(1), getVarTypeValRegex.matched(2)));
                commands.add(new Statement(getVarTypeValRegex.matched(1)+" = "+getVarTypeValRegex.matched(3)));
            }
            else if( getVarTypeRegex.match(stmt) )
            {
                vars.set(getVarTypeRegex.matched(1), new Var(getVarTypeRegex.matched(1), getVarTypeRegex.matched(2)));
            }
            else if( getVarValRegex.match(stmt) )
            {
                vars.set(getVarValRegex.matched(1), new Var(getVarValRegex.matched(1)));
                commands.add(new Statement(getVarValRegex.matched(1)+" = "+getVarValRegex.matched(2)));
            }
            else if( getVarRegex.match(stmt) )
            {
                vars.set(getVarRegex.matched(1), new Var(getVarRegex.matched(1)));
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
            for( ii in vars.keys() )
                vars.get(ii).isNew = false;
            imports.iter(  function(ii) ii.isNew = false );
            commands.iter( function(ii) ii.isNew = false );
        }
        else
        {
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
    public function getProgram()
    {
        var sb = new StringBuf();

        sb.add("import neko.Lib;\n");                       // imports
        for( ii in imports )
            sb.add(ii.toString() +"\n");

        sb.add("\n");

        sb.add("class IhxProgram {\n");
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
        return sb.toString();
    }
}
