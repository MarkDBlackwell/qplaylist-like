module View exposing (view)

import AssocSet as Set
import Html
import Html.Attributes
import Html.Events
import Html.Keyed
import Html.Lazy
import Model as M


view : M.Model -> Html.Html M.Msg
view model =
    let
        keyedSong : M.SlotTouchIndex -> M.Song -> ( String, Html.Html M.Msg )
        keyedSong index song =
            let
                key : String
                key =
                    String.concat
                        [ song.artist
                        , ": "
                        , song.time
                        , ": "
                        , song.title
                        ]

                lazySong : M.SlotTouchIndex -> Bool -> Html.Html M.Msg
                lazySong indexTouch likeHeart =
                    let
                        classHeart : M.Class
                        classHeart =
                            if likeHeart then
                                "like"

                            else
                                "aloof"
                    in
                    Html.div
                        [ Html.Events.onMouseUp (M.GotTouchEvent indexTouch) ]
                        [ Html.span [ Html.Attributes.class classHeart ] [] ]

                like : Bool
                like =
                    let
                        songsLike : M.Songs
                        songsLike =
                            Set.toList model.songsLike
                    in
                    List.member song songsLike
            in
            Html.Lazy.lazy2 lazySong index like
                |> Tuple.pair key
    in
    Html.Keyed.node
        "main"
        []
        (model.songsCurrent
            |> List.indexedMap keyedSong
        )
