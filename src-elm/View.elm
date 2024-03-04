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
        keyedSlots : List ( String, Html.Html M.Msg )
        keyedSlots =
            let
                classes : List M.Class
                classes =
                    let
                        class : Bool -> M.Class
                        class like =
                            if like then
                                "like"

                            else
                                "aloof"

                        member : M.Song -> Bool
                        member song =
                            let
                                songsLike : M.Songs
                                songsLike =
                                    Set.toList model.songsLike
                            in
                            List.member song songsLike
                    in
                    model.songsCurrent
                        |> List.map (class << member)

                keyedLazySlot : M.SlotTouchIndex -> M.Class -> ( String, Html.Html M.Msg )
                keyedLazySlot index class =
                    let
                        viewSong : M.SlotTouchIndex -> Html.Html M.Msg
                        viewSong _ =
                            Html.div
                                [ Html.Events.onMouseUp (M.GotTouchEvent index) ]
                                [ Html.span [ Html.Attributes.class class ] [] ]
                    in
                    Html.Lazy.lazy viewSong index
                        |> Tuple.pair (String.fromInt index)
            in
            List.indexedMap keyedLazySlot classes
    in
    Html.Keyed.node "main" [] keyedSlots
