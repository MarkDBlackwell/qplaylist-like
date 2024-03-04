module View exposing (view)

import AssocSet as Set
import Html
import Html.Attributes as A
import Html.Events
import Html.Keyed
import Html.Lazy
import Json.Decode as D
import Model as M


view : M.Model -> Html.Html M.Msg
view model =
    let
        slotClassesIndexed : List ( M.SlotTouchIndex, M.Class )
        slotClassesIndexed =
            let
                class : Bool -> M.Class
                class like =
                    if like then
                        "like"

                    else
                        "aloof"

                songsLike : M.Songs
                songsLike =
                    Set.toList model.songsLike
            in
            model.songsCurrent
                |> List.map (class << (\song -> List.member song songsLike))
                |> List.indexedMap Tuple.pair

        viewSlots : List ( String, Html.Html M.Msg )
        viewSlots =
            List.map (Html.Lazy.lazy viewSong) slotClassesIndexed
                |> List.indexedMap (\index x -> Tuple.pair (String.fromInt index) x)

        viewSong : ( M.SlotTouchIndex, M.Class ) -> Html.Html M.Msg
        viewSong ( index, class ) =
            Html.div
                [ Html.Events.onMouseUp (M.GotTouchEvent index) ]
                [ Html.span [ A.class class ] [] ]
    in
    Html.Keyed.node "main_"
        []
        viewSlots
