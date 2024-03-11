module Main exposing (main)

import Array
import AssocSet as Set
import Browser
import Decode as D
import Http
import Model as M
import Task
import Time
import Url.Builder as U
import View



-- ELM ARCHITECTURE


main : Program M.Channel M.Model M.Msg
main =
    Browser.element
        { init = M.init
        , update = update
        , subscriptions = M.subscriptions
        , view = View.view
        }



-- APPLICATION-SPECIFIC


appendPost : M.DirectionLike -> M.Song -> Cmd M.Msg
appendPost directionLike song =
    let
        contentType : String
        contentType =
            "application/x-www-form-urlencoded"

        payload : String
        payload =
            let
                items : List U.QueryParameter
                items =
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

                        transform : ( String, String ) -> U.QueryParameter
                        transform ( key, value ) =
                            U.string key value
                    in
                    List.map transform pairs

                queryIndicatorLength : Int
                queryIndicatorLength =
                    1
            in
            U.toQuery items
                |> String.dropLeft queryIndicatorLength

        url : String
        url =
            U.crossOrigin
                "https://wtmd.org"
                [ "like", "append.php" ]
                []
    in
    Http.post
        { body = Http.stringBody contentType payload
        , expect = Http.expectJson M.GotAppendResponse D.appendJsonDecoder
        , url = url
        }


latestFiveGet : M.Model -> Cmd M.Msg
latestFiveGet model =
    let
        url : String
        url =
            let
                basename : String
                basename =
                    String.concat
                        [ "LatestFive"
                        , model.channel
                        , ".json"
                        ]
            in
            U.relative
                [ "..", "playlist", "dynamic", basename ]
                []
    in
    Http.get
        { expect = Http.expectJson M.GotSongsResponse D.latestFiveJsonDecoder
        , url = url
        }



-- UPDATE


update : M.Msg -> M.Model -> ( M.Model, Cmd M.Msg )
update msg model =
    case msg of
        M.GotAppendResponse appendResult ->
            case appendResult of
                Err err ->
                    ( model
                    , Cmd.none
                    )

                Ok appendResponseString ->
                    ( model
                    , Cmd.none
                    )

        M.GotSongsResponse songsResult ->
            case songsResult of
                Err err ->
                    ( { model
                        --Retry.
                        | overallState = M.TimerActive
                      }
                    , Cmd.none
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
                                --Delay, then check again.
                                M.TimerActive

                            else
                                --Nothing to do (unless conditions change).
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

        M.GotTimeNow timeNow ->
            let
                delaySeconds : Int
                delaySeconds =
                    let
                        over : Int
                        over =
                            let
                                nowSeconds : Int
                                nowSeconds =
                                    let
                                        milliseconds : Int
                                        milliseconds =
                                            Time.posixToMillis timeNow
                                    in
                                    (milliseconds + 999) // 1000

                                phase : Int
                                phase =
                                    if String.isEmpty model.channel then
                                        0

                                    else
                                        standard // 2
                            in
                            nowSeconds - phase |> modBy standard

                        standard : Int
                        standard =
                            M.delayStandard
                    in
                    standard - over
            in
            ( { model
                | delaySeconds = delaySeconds
                , timeNow = timeNow
              }
            , Cmd.none
            )

        M.GotTimer _ ->
            ( { model
                --Always stop the timer after the first tick.
                | overallState = M.TimerIdle
              }
            , Cmd.batch
                [ Task.perform M.GotTimeNow Time.now

                --A song in our liked set may have just started.
                , latestFiveGet model
                ]
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
            , Cmd.batch
                [ Task.perform M.GotTimeNow Time.now
                , latestFiveGet model
                ]
            )
