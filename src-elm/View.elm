module View exposing (view)

import Html
import Html.Attributes as A
import Model



-- VIEW


divSong : Model.Class -> Html.Html Model.Msg
divSong class =
    Html.div []
        [ Html.span [ A.class class ] [] ]


heartClass : Model.Model -> Model.Song -> Model.Class
heartClass model song =
    let
        class : Bool -> Model.Class
        class liked =
            if liked then
                "like"

            else
                "aloof"
    in
    class
        (List.member song model.songsLiked)


heartClassFive : Model.Model -> List Model.Class
heartClassFive model =
    List.map (heartClass model) model.songsCurrent


view : Model.Model -> Html.Html Model.Msg
view model =
    Html.main_ [] <|
        List.map divSong (heartClassFive model)
