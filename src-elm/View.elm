module View exposing (view)

import Html
import Html.Attributes as A
import Model as M



-- VIEW


divSong : M.Class -> Html.Html M.Msg
divSong class =
    Html.div []
        [ Html.span [ A.class class ] [] ]


heartClass : M.Model -> M.Song -> M.Class
heartClass model song =
    let
        class : Bool -> M.Class
        class liked =
            if liked then
                "like"

            else
                "aloof"
    in
    class
        (List.member song model.songsLiked)


heartClassFive : M.Model -> List M.Class
heartClassFive model =
    List.map (heartClass model) model.songsCurrent


view : M.Model -> Html.Html M.Msg
view model =
    Html.main_ [] <|
        List.map divSong (heartClassFive model)
