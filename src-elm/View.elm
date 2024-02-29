module View exposing (view)

import Html
import Html.Attributes as A
import Html.Events
import Json.Decode as D
import Model as M
import Set


view : M.Model -> Html.Html M.Msg
view model =
    let
        tuples : List ( M.SlotTouchIndex, M.Class )
        tuples =
            let
                heartClasses : List M.Class
                heartClasses =
                    let
                        heartClass : Bool -> M.Class
                        heartClass like =
                            if like then
                                "like"

                            else
                                "aloof"

                        songsLikeList : M.Songs
                        songsLikeList =
                            Set.toList model.songsLike
                    in
                    model.songsCurrent
                        |> List.map (\x -> List.member x songsLikeList)
                        |> List.map heartClass
            in
            List.indexedMap Tuple.pair heartClasses

        viewSong : ( M.SlotTouchIndex, M.Class ) -> Html.Html M.Msg
        viewSong ( index, class ) =
            Html.div
                [ Html.Events.onMouseUp (M.GotTouchEvent index) ]
                [ Html.span [ A.class class ] [] ]
    in
    Html.main_ []
        (List.map viewSong tuples)
