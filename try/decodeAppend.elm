import Json.Decode as D

appendResponseStringJson =
    """{"response":"good"}"""

type alias AppendJsonRoot =
    { response : String
    }

appendJsonDecoder =
    D.map AppendJsonRoot
        (D.field "response" D.string)

D.decodeString appendJsonDecoder appendResponseStringJson
