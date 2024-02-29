module Main exposing (main)

import Array
import AssocSet as Set
import Browser
import Http
import Json.Decode as D
import Model as M
import View


appendPost : M.DirectionLike -> M.Song -> Cmd M.Msg
appendPost directionLike song =
    let
        contentType : String
        contentType =
            "application/x-www-form-urlencoded"

        direction : String
        direction =
            case directionLike of
                M.SendLike ->
                    "l"

                M.SendUnlike ->
                    "u"

        payload : String
        payload =
            String.concat
                [ "direction"
                , "="
                , direction
                , "&"
                , "song_artist"
                , "="
                , song.artist
                , "&"
                , "song_title"
                , "="
                , song.title
                ]
    in
    Http.post
        { body = Http.stringBody contentType payload
        , expect = Http.expectJson M.GotAppendResponse appendJsonDecoder
        , url = "../playlist/append.json"
        }


appendJsonDecoder : D.Decoder M.AppendResponseString
appendJsonDecoder =
    D.map (.response << M.AppendJsonRoot)
        (D.field "response" D.string)


latestFiveGet : Cmd M.Msg
latestFiveGet =
    Http.get
        { expect = Http.expectJson M.GotSongsCurrentResponse latestFiveJsonDecoder
        , url = "../playlist/dynamic/LatestFiveHD2.json"
        }


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
                            let
                                flat : List (Cmd M.Msg)
                                flat =
                                    List.concat
                                        [ Set.toList songsToUnlike
                                            |> List.map
                                                (appendPost M.SendUnlike)
                                        , Set.toList songsToLike
                                            |> List.map
                                                (appendPost M.SendLike)
                                        ]
                            in
                            Cmd.batch flat

                        ignored =
                            Debug.log "songsCurrent" songsCurrent

                        ignoredSlotsSelectedSongs =
                            Debug.log "slotsSelectedSongs" slotsSelectedSongs

                        ignoredSongsToLike =
                            Debug.log "songsToLike" songsToLike

                        ignoredSongsToUnlike =
                            Debug.log "songsToUnlike" songsToUnlike

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

                        slotsSelectedList : M.SlotsSelectedList
                        slotsSelectedList =
                            Array.toList model.slotsSelected

                        slotsSelectedSongs : M.Songs
                        slotsSelectedSongs =
                            List.map2 Tuple.pair slotsSelectedList songsCurrent
                                |> List.filter Tuple.first
                                |> List.map Tuple.second

                        slotsSelectedSongsSet : M.SongsLike
                        slotsSelectedSongsSet =
                            Set.fromList slotsSelectedSongs

                        songsLike : M.SongsLike
                        songsLike =
                            Set.diff model.songsLike songsToUnlike
                                |> Set.union songsToLike

                        songsLikeList : M.Songs
                        songsLikeList =
                            Set.toList model.songsLike

                        songsToLike : M.SongsLike
                        songsToLike =
                            Set.diff slotsSelectedSongsSet model.songsLike

                        songsToUnlike : M.SongsLike
                        songsToUnlike =
                            Set.intersect slotsSelectedSongsSet model.songsLike
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
            let
                command : Cmd M.Msg
                command =
                    case overallState of
                        M.HaveActiveLikes ->
                            latestFiveGet

                        M.Idle ->
                            Cmd.none

                ignored =
                    Debug.log "got time tick" 0

                ignoredOverallState =
                    Debug.log "overallState" overallState

                ignoredSlotsSelected =
                    Debug.log "model.slotsSelected" model.slotsSelected

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

                        slotsSelectedAny : Bool
                        slotsSelectedAny =
                            Array.foldl (||) False model.slotsSelected
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
                        latestFiveGet

                    else
                        Cmd.none

                ignored =
                    Debug.log "got touch event" slotTouchIndex

                ignoredOverallState =
                    Debug.log "overallState" overallState

                ignoredSlotsSelected =
                    Debug.log "slotsSelected" slotsSelected

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
           [ latestFiveGet
           , Http.post
               { body = Http.stringBody contentType payload
               , expect = Http.expectJson M.GotAppendResponse appendJsonDecoder
               , url = "../playlist/append.json"
               }
           ]
       )
       , Cmd.batch
           [ latestFiveGet
           , Http.post
               { body = Http.stringBody contentType payload
               , expect = Http.expectJson M.GotAppendResponse appendJsonDecoder
               , url = "../playlist/append.json"
               }
           ]
-}
