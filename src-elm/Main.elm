module Main exposing (main)

import Html
import Html.Attributes as A


main =
    Html.main_
        []
        [ Html.div
            []
            [ Html.span
                [ A.class "aloof" ]
                []
            ]
        , Html.div
            []
            [ Html.span
                [ A.class "like" ]
                []
            ]
        , Html.div
            []
            [ Html.span
                [ A.class "aloof" ]
                []
            ]
        , Html.div
            []
            [ Html.span
                [ A.class "aloof" ]
                []
            ]
        , Html.div
            []
            [ Html.span
                [ A.class "aloof" ]
                []
            ]
        ]
