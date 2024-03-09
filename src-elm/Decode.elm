module Decode exposing (..)

import Json.Decode as D
import Model as M


appendJsonDecoder : D.Decoder M.AppendResponseString
appendJsonDecoder =
    D.map (.response << M.AppendJsonRoot)
        (D.field "response" D.string)


latestFiveJsonDecoder : D.Decoder M.Songs
latestFiveJsonDecoder =
    let
        songJsonDecoder : D.Decoder M.Song
        songJsonDecoder =
            D.map3 M.Song
                (D.field "artist" D.string)
                (D.field "time" D.string)
                (D.field "title" D.string)
    in
    D.map (List.take M.slotsCount << .latestFive << M.LatestFiveJsonRoot)
        (D.field "latestFive" <| D.list songJsonDecoder)
