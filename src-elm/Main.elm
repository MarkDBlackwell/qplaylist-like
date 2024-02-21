module Main exposing (main)

import Html
import Html.Attributes as A


classes =
    [ "aloof"
    , "aloof"
    , "aloof"
    , "aloof"
    , "like"
    ]


div class =
    Html.div
        []
        [ Html.span
            [ A.class class ]
            []
        ]


divs =
    List.map div classes


htmlOutput =
    Html.main_
        []
        divs


main =
    htmlOutput
