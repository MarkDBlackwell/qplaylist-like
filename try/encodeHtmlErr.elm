import Http
import Json.Encode as E

type Msg
  = GotText (Result Http.Error String)

type Error
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Int
    | BadBody String

get : Cmd Msg
get =
    let
        url : String
        url =
            "https://wtmd.org/like/junk.php"
    in
    Http.get
        { expect = Http.expectString GotText
        , url = url
        }
