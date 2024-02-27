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
        , subscriptions = subscriptions
        , view = View.view
        }


songJsonDecoder : D.Decoder M.Song
songJsonDecoder =
    D.map2 M.Song
        (D.field "artist" D.string)
        (D.field "title" D.string)



-- UPDATE
{-
   , Http.get
       { url = "dynamic/LatestFive.json"
       , expect = Http.expectJson M.GotSongsResponse decoderSongs
       }

   appendForm artist title =
       Html.form
           [ A.action "append.json"
           , A.method "post"
           ]
           [ Html.input
               [ A.name "direction"
               , A.value "l"
               ]
           , Html.input
               [ A.name "song_artist"
               , A.value artist
               ]
           , Html.input
               [ A.name "song_title"
               , A.value title
               ]
           ]
-}


update : M.Msg -> M.Model -> ( M.Model, Cmd M.Msg )
update msg model =
    case msg of
        M.GotAppendResponse resultAppend ->
            case resultAppend of
                Err _ ->
                    ( model
                    , Cmd.none
                    )

                Ok appendResponseString ->
                    case D.decodeString appendJsonDecoder appendResponseString of
                        Err _ ->
                            ( model
                            , Cmd.none
                            )

                        Ok appendDecoded ->
                            ( model
                            , Cmd.none
                            )

        M.GotSongsResponse resultSongs ->
            case resultSongs of
                Err _ ->
                    ( model
                    , Cmd.none
                    )

                Ok latestFiveResponseString ->
                    case D.decodeString latestFiveJsonDecoder latestFiveResponseString of
                        Err _ ->
                            ( model
                            , Cmd.none
                            )

                        Ok songsDecoded ->
                            ( model
                            , Cmd.none
                            )

        M.GotTouchEvent ->
            ( model
            , Http.post
                { url = "append.json"
                , body = Http.stringBody "direction=l&song_artist=a+new&song_title=a+new+title"
                , expect = Http.expectJson M.GotAppendResponse
                }
            )



-- SUBSCRIPTIONS


subscriptions : M.Model -> Sub M.Msg
subscriptions model =
    Sub.none
