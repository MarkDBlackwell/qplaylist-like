port module Port exposing (logConsole)

-- PORTS


--TODO: Don't bother to log to the console.
--I checked Google Chrome, and browsers themselves log XHR errors to the console.
port logConsole : String -> Cmd msg
