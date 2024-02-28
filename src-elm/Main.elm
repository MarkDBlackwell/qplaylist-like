module Main exposing (main)

import Browser
import Http
import Json.Decode as D
import Model as M
import View


appendJsonDecoder : D.Decoder M.AppendResponseString
appendJsonDecoder =
    D.map (.response << M.AppendJsonRoot)
        (D.field "response" D.string)


latestFiveJsonDecoder : D.Decoder M.Songs
latestFiveJsonDecoder =
    D.map (List.take M.songsCurrentCountMax << .latestFive << M.LatestFiveJsonRoot)
        (D.field "latestFive" <| D.list songJsonDecoder)


main : Program () M.Model M.Msg
main =
    Browser.element
        { init = M.init
        , update = update
        , subscriptions = M.subscriptions
        , view = View.view
        }


songJsonDecoder : D.Decoder M.Song
songJsonDecoder =
    D.map2 M.Song
        (D.field "artist" D.string)
        (D.field "title" D.string)



-- UPDATE


update : M.Msg -> M.Model -> ( M.Model, Cmd M.Msg )
update msg model =
    case msg of
        M.GotAppendResponse appendResult ->
            case appendResult of
                Err err ->
                    let
                        ignored =
                            Debug.log "appendResult error" err
                    in
                    ( model
                    , Cmd.none
                    )

                Ok appendResponseString ->
                    let
                        ignored =
                            Debug.log "appendResponseString" appendResponseString
                    in
                    ( model
                    , Cmd.none
                    )

        M.GotSongsCurrentResponse songsCurrentResult ->
            case songsCurrentResult of
                Err err ->
                    let
                        ignored =
                            Debug.log "songsCurrentResult error" err
                    in
                    ( model
                    , Cmd.none
                    )

                Ok songsCurrent ->
                    let
                        commands : Cmd M.Msg
                        commands =
                            Cmd.none

                        ignored =
                            Debug.log "songsCurrent" songsCurrent

                        overallStateNew : M.OverallState
                        overallStateNew =
                            let
                                activeLikesPresent : Bool
                                activeLikesPresent =
                                    List.any
                                        (\x -> List.member x songsCurrent)
                                        model.songsLike
                            in
                            if activeLikesPresent then
                                M.HaveActiveLikes

                            else
                                M.Idle
                    in
                    ( { model
                        | overallState = overallStateNew
                        , songsCurrent = songsCurrent
                      }
                    , commands
                    )

        M.GotTimeTick timePosix ->
            let
                ignored =
                    Debug.log "got time tick" 0
            in
            ( { model | overallState = M.Idle }
            , Cmd.none
            )

        M.GotTouchEvent slotTouchIndex ->
            let
                contentType : String
                contentType =
                    "application/x-www-form-urlencoded"

                ignored =
                    Debug.log "got touch event" slotTouchIndex

                payload : String
                payload =
                    let
                        artist : String
                        artist =
                            "a new artist"

                        direction : String
                        direction =
                            "l"

                        title : String
                        title =
                            "a new title"
                    in
                    "direction=" ++ direction ++ "&song_artist=" ++ artist ++ "&song_title=" ++ title
            in
            ( model
            , Cmd.batch
                [ Http.get
                    { expect = Http.expectJson M.GotSongsCurrentResponse latestFiveJsonDecoder
                    , url = "../playlist/dynamic/LatestFive.json"
                    }
                , Http.post
                    { body = Http.stringBody contentType payload
                    , expect = Http.expectJson M.GotAppendResponse appendJsonDecoder
                    , url = "../playlist/append.json"
                    }
                ]
            )
