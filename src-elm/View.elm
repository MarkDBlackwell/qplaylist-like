module View exposing (view)

import AssocSet as Set
import Html
import Html.Attributes as A
import Html.Events
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

        viewSong : ( M.SlotTouchIndex, M.Class ) -> Html.Html M.Msg
        viewSong ( index, class ) =
            Html.div
                [ Html.Events.onMouseUp (M.GotTouchEvent index) ]
                [ Html.span [ A.class class ] [] ]
    in
    Html.main_ []
        (List.map viewSong slotClassesIndexed)
