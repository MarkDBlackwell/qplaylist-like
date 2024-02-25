module View exposing (htmlOutput)

import Data
import Html
import Html.Attributes as A


divSong class =
    Html.div []
        [ Html.span [ A.class class ] [] ]


heartClass song =
    let
        class liked =
            if liked then
                "like"

            else
                "aloof"
    in
    Data.songsLiked
        |> List.member song
        |> class


heartClassFive =
    List.map heartClass Data.songsCurrent


htmlOutput =
    List.map divSong heartClassFive
        |> Html.main_ []


view : Model -> Html Msg
view = _ htmlOutput
