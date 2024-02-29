module Main exposing (main)

import Array
import Browser
import Http
import Json.Decode as D
import Model as M
import Set
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
                        command : Cmd M.Msg
                        command =
                            Cmd.none

                        ignored =
                            Debug.log "songsCurrent" songsCurrent

                        likesToProcess : M.Songs
                        likesToProcess =
                            model.likesToProcess

                        overallState : M.OverallState
                        overallState =
                            let
                                activeLikePresent : Bool
                                activeLikePresent =
                                    List.any
                                        (\x -> List.member x songsCurrent)
                                        songsLikeList

                                slotsSelectedAny : Bool
                                slotsSelectedAny =
                                    Array.foldl (||) False model.slotsSelected
                            in
                            if activeLikePresent || slotsSelectedAny then
                                M.HaveActiveLikes

                            else
                                M.Idle

                        slotsSelected : M.SlotsSelected
                        slotsSelected =
                            model.slotsSelected

                        songsLike : M.SongsLike
                        songsLike =
                            model.songsLike

                        songsLikeList : M.Songs
                        songsLikeList =
                            Set.toList songsLike

                        unlikesToProcess : M.Songs
                        unlikesToProcess =
                            model.unlikesToProcess
                    in
                    ( { model
                        | likesToProcess = likesToProcess
                        , overallState = overallState
                        , slotsSelected = slotsSelected
                        , songsCurrent = songsCurrent
                        , songsLike = songsLike
                        , unlikesToProcess = unlikesToProcess
                      }
                    , command
                    )

        M.GotTimeTick timePosix ->
            let
                command : Cmd M.Msg
                command =
                    case overallState of
                        M.Idle ->
                            Cmd.none

                        M.HaveActiveLikes ->
                            Http.get
                                { expect = Http.expectJson M.GotSongsCurrentResponse latestFiveJsonDecoder
                                , url = "../playlist/dynamic/LatestFive.json"
                                }

                ignored =
                    Debug.log "got time tick" 0

                overallState : M.OverallState
                overallState =
                    let
                        activeLikePresent : Bool
                        activeLikePresent =
                            List.any
                                (\x -> List.member x model.songsCurrent)
                                songsLikeList

                        slotsSelectedAny : Bool
                        slotsSelectedAny =
                            Array.foldl (||) False model.slotsSelected

                        songsLikeList : M.Songs
                        songsLikeList =
                            Set.toList model.songsLike
                    in
                    if activeLikePresent || slotsSelectedAny then
                        M.HaveActiveLikes

                    else
                        M.Idle
            in
            ( { model | overallState = overallState }
            , command
            )

        M.GotTouchEvent slotTouchIndex ->
            let
                command : Cmd M.Msg
                command =
                    if slotsSelectedAny then
                        Http.get
                            { expect = Http.expectJson M.GotSongsCurrentResponse latestFiveJsonDecoder
                            , url = "../playlist/dynamic/LatestFive.json"
                            }

                    else
                        Cmd.none

                ignored =
                    Debug.log "got touch event" slotTouchIndex

                overallState : M.OverallState
                overallState =
                    let
                        activeLikePresent : Bool
                        activeLikePresent =
                            List.any
                                (\x -> List.member x model.songsCurrent)
                                songsLikeList

                        songsLikeList : M.Songs
                        songsLikeList =
                            Set.toList model.songsLike
                    in
                    if activeLikePresent || slotsSelectedAny then
                        M.HaveActiveLikes

                    else
                        M.Idle

                slotsSelected : M.SlotsSelected
                slotsSelected =
                    let
                        slotThis : Bool
                        slotThis =
                            Array.get slotTouchIndex model.slotsSelected
                                |> Maybe.withDefault False
                    in
                    Array.set slotTouchIndex
                        (not slotThis)
                        model.slotsSelected

                slotsSelectedAny : Bool
                slotsSelectedAny =
                    Array.foldl (||) False slotsSelected
            in
            ( { model
                | overallState = overallState
                , slotsSelected = slotsSelected
              }
            , command
            )



{-
   G O E S  S O M E W H E R E  E L S E ->
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
-}
