module Model exposing (..)

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
    { likesToProcess : Songs
    , overallState : OverallState
    , selectedSlotsToProcess : SelectedSlotsToProcess
    , songsCurrent : Songs
    , songsLike : Songs
    , unlikesToProcess : Songs
    }


type alias SelectedSlotsToProcess =
    List SlotTouchIndex


type alias SlotTouchIndex =
    Int


type alias Song =
    { artist : Artist
    , title : Title
    }


type alias Songs =
    List Song


type alias StringJson =
    String


type alias Title =
    String


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
    ( { likesToProcess = []
      , overallState = Idle
      , selectedSlotsToProcess = []
      , songsCurrent = songsCurrentInit
      , songsLike = []
      , unlikesToProcess = []
      }
    , Cmd.none
    )


songEmpty : Song
songEmpty =
    Song "" ""


songsCurrentInit : Songs
songsCurrentInit =
    List.repeat songsCurrentCountMax songEmpty



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
