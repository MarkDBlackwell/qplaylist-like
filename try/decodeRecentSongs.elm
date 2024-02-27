import Json.Decode as D

latestFiveResponseStringJson =
    """{
        "latestFive": [
            {
                "artist": "Tears of Mars",
                "title": "Equity (Desk 41 Remix)",
                "time": "5:12 AM",
                "timeStamp": "2024 02 26 05 12"
            },
            {
                "artist": "Soul Cannon",
                "title": "Still Something To Give",
                "time": "5:09 AM",
                "timeStamp": "2024 02 26 05 09"
            },
            {
                "artist": "The Everlove",
                "title": "You're the Sun",
                "time": "5:05 AM",
                "timeStamp": "2024 02 26 05 05"
            },
            {
                "artist": "Squaaks",
                "title": "The Story Goes",
                "time": "5:02 AM",
                "timeStamp": "2024 02 26 05 02"
            },
            {
                "artist": "Lazlo Lee and the Motherless",
                "title": "Hey Doctor",
                "time": "5:00 AM",
                "timeStamp": "2024 02 26 05 00"
            }
        ]
    }"""

type alias Song =
    { artist : String
    , title : String
    }

type alias LatestFiveJsonRoot =
    { latestFive : List Song
    }

latestFiveSongJsonDecoder =
    D.map2 Song
        (D.field "artist" D.string)
        (D.field "title" D.string)

latestFiveJsonDecoder =
    D.map LatestFiveJsonRoot
        (D.field "latestFive" <| D.list latestFiveSongJsonDecoder)

D.decodeString latestFiveJsonDecoder latestFiveResponseStringJson
