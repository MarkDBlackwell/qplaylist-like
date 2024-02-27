module Main exposing (main)

import Browser
import Http
import Json.Decode as D
import Model
import View


appendJsonDecoder : D.Decoder Model.AppendJsonRoot
appendJsonDecoder =
    D.map Model.AppendJsonRoot
        (D.field "response" D.string)


latestFiveJsonDecoder : D.Decoder Model.LatestFiveJsonRoot
latestFiveJsonDecoder =
    D.map Model.LatestFiveJsonRoot
        (D.field "latestFive" <| D.list songJsonDecoder)


main : Program () Model.Model Model.Msg
main =
    Browser.element
        { init = Model.init
        , update = update
        , subscriptions = subscriptions
        , view = View.view
        }


songJsonDecoder : D.Decoder Model.Song
songJsonDecoder =
    D.map2 Model.Song
        (D.field "artist" D.string)
        (D.field "title" D.string)



-- UPDATE
{-
   , Http.get
       { url = "dynamic/LatestFive.json"
       , expect = Http.expectJson Model.GotSongsResponse decoderSongs
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


update : Model.Msg -> Model.Model -> ( Model.Model, Cmd Model.Msg )
update msg model =
    case msg of
        Model.GotAppendResponse resultAppend ->
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

        Model.GotSongsResponse resultSongs ->
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

        Model.GotTouchEvent ->
            ( model
            , Http.post
                { url = "append.json"
                , body = Http.stringBody "direction=l&song_artist=a+new&song_title=a+new+title"
                , expect = Http.expectJson Model.GotAppendResponse
                }
            )



-- SUBSCRIPTIONS


subscriptions : Model.Model -> Sub Model.Msg
subscriptions model =
    Sub.none
