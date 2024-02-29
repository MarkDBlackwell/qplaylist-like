module Model exposing (..)

import Array
import AssocSet as Set
import Http
import Task
import Time


type alias AppendJsonRoot =
    { response : String }


type alias AppendResponseString =
    String


type alias Artist =
    String


type alias Class =
    String


type alias LatestFiveJsonRoot =
    { latestFive : Songs }


type alias Model =
    { overallState : OverallState
    , slotsSelected : SlotsSelected
    , songsCurrent : Songs
    , songsLike : SongsLike
    }


type alias SlotsSelected =
    Array.Array Bool


type alias SlotsSelectedList =
    List Bool


type alias SlotTouchIndex =
    Int


type alias Song =
    { artist : Artist
    , title : Title
    }


type alias Songs =
    List Song


type alias SongsLike =
    Set.Set Song


type alias StringJson =
    String


type alias Title =
    String


type DirectionLike
    = SendLike
    | SendUnlike


type Msg
    = GotAppendResponse (Result Http.Error AppendResponseString)
    | GotSongsCurrentResponse (Result Http.Error Songs)
    | GotTimeTick Time.Posix
    | GotTouchEvent SlotTouchIndex


type OverallState
    = HaveActiveLikes
    | Idle


cmdMsg2Cmd : Msg -> Cmd Msg
cmdMsg2Cmd msg =
    --See:
    --  http://github.com/billstclair/elm-dynamodb/blob/7ac30d60b98fbe7ea253be13f5f9df4d9c661b92/src/DynamoBackend.elm
    --For wrapping a message as a Cmd:
    msg
        |> Task.succeed
        |> Task.perform
            identity


songsCurrentCountMax : Int
songsCurrentCountMax =
    5



-- INITIALIZATION


init : () -> ( Model, Cmd Msg )
init _ =
    ( { overallState = Idle
      , slotsSelected = slotsSelectedInit
      , songsCurrent = songsCurrentInit
      , songsLike = songsLikeInit
      }
    , Cmd.none
    )


slotsSelectedInit : SlotsSelected
slotsSelectedInit =
    Array.repeat songsCurrentCountMax False


songEmpty : Song
songEmpty =
    Song "" ""


songsCurrentInit : Songs
songsCurrentInit =
    List.repeat songsCurrentCountMax songEmpty


songsLikeInit : SongsLike
songsLikeInit =
    Set.empty



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        delaySeconds : Float
        delaySeconds =
            20.0
    in
    case model.overallState of
        HaveActiveLikes ->
            Time.every (delaySeconds * 1000.0) GotTimeTick

        _ ->
            Sub.none
