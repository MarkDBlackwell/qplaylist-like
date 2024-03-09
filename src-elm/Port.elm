port module Port exposing (logConsole)

-- PORTS
--TODO: Don't bother to log to the console.
----Google Chrome shows XHR errors in the Web Console.
----Firefox shows XHR errors in the Network Monitor.


port logConsole : String -> Cmd msg
