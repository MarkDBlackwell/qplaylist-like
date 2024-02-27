module Main exposing (main)

import Browser
import Http
import Json.Decode as D
import Model as M
import View


appendJsonDecoder : D.Decoder M.AppendJsonRoot
appendJsonDecoder =
    D.map M.AppendJsonRoot
        (D.field "response" D.string)


latestFiveJsonDecoder : D.Decoder M.LatestFiveJsonRoot
latestFiveJsonDecoder =
    D.map M.LatestFiveJsonRoot
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
        M.GotAppendResponse resultAppend ->
            case resultAppend of
                Err err ->
                    let
                        ignored =
                            Debug.log "resultAppend error" err
                    in
                    ( model
                    , Cmd.none
                    )

                Ok appendJsonRoot ->
                    let
                        ignored =
                            Debug.log "appendJsonRoot" appendJsonRoot
                    in
                    ( model
                    , Cmd.none
                    )

        M.GotSongsResponse resultSongs ->
            case resultSongs of
                Err err ->
                    let
                        ignored =
                            Debug.log "resultSongs error" err
                    in
                    ( model
                    , Cmd.none
                    )

                Ok latestFiveJsonRoot ->
                    let
                        ignored =
                            Debug.log "latestFiveJsonRoot" latestFiveJsonRoot
                    in
                    ( model
                    , Cmd.none
                    )

        M.GotTimeTick timePosix ->
            let
                contentType =
                    "application/x-www-form-urlencoded"

                ignored =
                    Debug.log "got time tick" 0

                payload =
                    "direction=l&song_artist=a+new&song_title=a+new+title"
            in
            ( model
            , Cmd.batch
                [ Http.post
                    { body = Http.stringBody contentType payload
                    , expect = Http.expectJson M.GotAppendResponse appendJsonDecoder
                    , url = "append.json"
                    }
                , Http.get
                    { expect = Http.expectJson M.GotSongsResponse latestFiveJsonDecoder
                    , url = "dynamic/LatestFive.json"
                    }
                ]
            )

        M.GotTouchEvent ->
            ( model
            , Cmd.none
            )
