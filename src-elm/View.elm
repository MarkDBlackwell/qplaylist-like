module View exposing (view)

import Html
import Html.Attributes as A
import Model as M



-- VIEW


view : M.Model -> Html.Html M.Msg
view model =
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
            in
            model.songsCurrent
                |> List.map (\x -> List.member x model.songsLike)
                |> List.map heartClass
    in
    Html.main_ []
        (List.map viewSong heartClasses)


viewSong : M.Class -> Html.Html M.Msg
viewSong class =
    Html.div []
        [ Html.span [ A.class class ] [] ]
