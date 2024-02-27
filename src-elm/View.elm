module View exposing (view)

import Html
import Html.Attributes as A
import Model



-- VIEW


divSong class =
    Html.div []
        [ Html.span [ A.class class ] [] ]


heartClass model song =
    let
        class liked =
            if liked then
                "like"

            else
                "aloof"
    in
    class
        (List.member song model.songsLiked)


heartClassFive model =
    List.map (heartClass model) model.songsCurrent


view model =
    Html.main_ [] <|
        List.map divSong (heartClassFive model)
