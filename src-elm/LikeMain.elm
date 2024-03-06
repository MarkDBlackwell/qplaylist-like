module LikeMain exposing (main)

import Array
import AssocSet as Set
import Browser
import Http
import Json.Decode as D
import Model as M
import Port as P
import View


appendJsonDecoder : D.Decoder M.AppendResponseString
appendJsonDecoder =
    D.map (.response << M.AppendJsonRoot)
        (D.field "response" D.string)


appendPost : M.DirectionLike -> M.Song -> Cmd M.Msg
appendPost directionLike song =
    let
        contentType : String
        contentType =
            "application/x-www-form-urlencoded"

        payload : String
        payload =
            let
                assignments : List String
                assignments =
                    let
                        pairs : List ( String, String )
                        pairs =
                            let
                                direction : String
                                direction =
                                    case directionLike of
                                        M.SendLike ->
                                            "l"

                                        M.SendUnlike ->
                                            "u"
                            in
                            [ ( "direction", direction )
                            , ( "song_artist", song.artist )
                            , ( "song_title", song.title )
                            ]
                    in
                    List.map
                        (\( x, y ) -> String.concat [ x, "=", y ])
                        pairs
            in
            List.intersperse "&" assignments
                |> String.concat

        url : String
        url =
            "https://wtmd.org/like/append.php"
    in
    Http.post
        { body = Http.stringBody contentType payload
        , expect = Http.expectJson M.GotAppendResponse appendJsonDecoder
        , url = url
        }


latestFiveGet : M.Model -> Cmd M.Msg
latestFiveGet model =
    let
        url : String
        url =
            String.concat
                [ "../playlist/dynamic/LatestFive"
                , model.channel
                , ".json"
                ]
    in
    Http.get
        { expect = Http.expectJson M.GotSongsResponse latestFiveJsonDecoder
        , url = url
        }


latestFiveJsonDecoder : D.Decoder M.Songs
latestFiveJsonDecoder =
    D.map (List.take M.slotsCount << .latestFive << M.LatestFiveJsonRoot)
        (D.field "latestFive" <| D.list songJsonDecoder)


main : Program M.Channel M.Model M.Msg
main =
    Browser.element
        { init = M.init
        , update = update
        , subscriptions = M.subscriptions
        , view = View.view
        }


songJsonDecoder : D.Decoder M.Song
songJsonDecoder =
    D.map3 M.Song
        (D.field "artist" D.string)
        (D.field "time" D.string)
        (D.field "title" D.string)



-- UPDATE


update : M.Msg -> M.Model -> ( M.Model, Cmd M.Msg )
update msg model =
    case msg of
        M.GotAppendResponse appendResult ->
            case appendResult of
                Err err ->
                    let
                        --ignored =
                        --Debug.log message err
                        message : String
                        message =
                            "appendResult error"
                    in
                    ( model
                    , P.logConsole message
                    )

                Ok appendResponseString ->
                    ( model
                    , Cmd.none
                    )

        M.GotSongsResponse songsResult ->
            case songsResult of
                Err err ->
                    let
                        --ignored =
                        --Debug.log message err
                        message : String
                        message =
                            "songsResult error"
                    in
                    ( model
                    , P.logConsole message
                    )

                Ok songsCurrent ->
                    let
                        commands : Cmd M.Msg
                        commands =
                            let
                                posts : List (Cmd M.Msg)
                                posts =
                                    List.concat
                                        [ List.map
                                            (appendPost M.SendUnlike)
                                            (Set.toList songsToUnlike)
                                        , List.map
                                            (appendPost M.SendLike)
                                            (Set.toList songsToLike)
                                        ]
                            in
                            Cmd.batch posts

                        overallState : M.OverallState
                        overallState =
                            let
                                slotsSelectedAny : Bool
                                slotsSelectedAny =
                                    model.slotsSelected /= M.slotsSelectedInit

                                songsLikeAny : Bool
                                songsLikeAny =
                                    List.any
                                        (\song -> List.member song songsCurrent)
                                        (Set.toList model.songsLike)
                            in
                            if songsLikeAny || slotsSelectedAny then
                                M.TimerActive

                            else
                                M.TimerIdle

                        songsLike : M.SongsLike
                        songsLike =
                            songsToUnlike
                                |> Set.diff model.songsLike
                                |> Set.union songsToLike

                        songsToLike : M.SongsLike
                        songsToLike =
                            Set.diff songsToToggle model.songsLike

                        songsToToggle : M.SongsLike
                        songsToToggle =
                            Array.toList model.slotsSelected
                                |> List.map2 Tuple.pair songsCurrent
                                |> List.filter Tuple.second
                                |> List.map Tuple.first
                                |> Set.fromList

                        songsToUnlike : M.SongsLike
                        songsToUnlike =
                            Set.intersect songsToToggle model.songsLike
                    in
                    ( { model
                        | overallState = overallState
                        , slotsSelected = M.slotsSelectedInit
                        , songsCurrent = songsCurrent
                        , songsLike = songsLike
                      }
                    , commands
                    )

        M.GotTimeTick timePosix ->
            ( { model
                | overallState = M.TimerIdle
              }
              --A song in our liked set may have just started.
            , latestFiveGet model
            )

        M.GotTouchEvent slotTouchIndex ->
            let
                slotsSelected : M.SlotsSelected
                slotsSelected =
                    Array.set slotTouchIndex True model.slotsSelected
            in
            ( { model
                | overallState = M.TimerIdle
                , slotsSelected = slotsSelected
              }
            , latestFiveGet model
            )
