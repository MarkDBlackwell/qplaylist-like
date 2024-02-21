module View exposing (..)

import Data
import Html
import Html.Attributes as A


divSong liked =
    let
        class =
            if liked then
                "like"

            else
                "aloof"
    in
    Html.div
        []
        [ Html.span
            [ A.class class ]
            []
        ]


divs =
    let
        fiveLiked =
            List.map (\song -> List.member song Data.likes) Data.songsCurrent
    in
    List.map divSong fiveLiked


htmlOutput =
    Html.main_
        []
        divs
