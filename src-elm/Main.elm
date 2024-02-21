module Main exposing (main)

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
            List.map (\song -> List.member song likes) songsCurrent
    in
    List.map divSong fiveLiked


htmlOutput =
    Html.main_
        []
        divs


likes =
    [ ( "Bob", "Highway 51 Revisited" )
    , ( "Alice", "Wonderland" )
    ]


main =
    htmlOutput


songsCurrent =
    [ ( "Charlie", "Chan" )
    , ( "Dave", "Brubeck" )
    , ( "Alice", "Wonderland" )
    , ( "Frank", "Diary" )
    , ( "Edger", "A. Poe" )
    ]
