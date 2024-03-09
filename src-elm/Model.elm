module Model exposing (..)

import Array
import AssocSet as Set
import Http
import Time



-- ELM ARCHITECTURE


type alias Model =
    { channel : Channel
    , delaySeconds : Int
    , overallState : OverallState
    , slotsSelected : SlotsSelected
    , songsCurrent : Songs
    , songsLike : SongsLike
    , timeNow : Time.Posix
    }


type Msg
    = GotAppendResponse (Result Http.Error AppendResponseString)
    | GotSongsResponse (Result Http.Error Songs)
    | GotTimeNow Time.Posix
    | GotTimer Time.Posix
    | GotTouchEvent SlotTouchIndex



-- INITIALIZATION


init : Channel -> ( Model, Cmd Msg )
init channel =
    let
        songsCurrentInit : Songs
        songsCurrentInit =
            let
                songEmpty : Song
                songEmpty =
                    Song "" "" ""
            in
            List.repeat slotsCount songEmpty
    in
    ( { channel = channel
      , delaySeconds = 0
      , overallState = TimerIdle
      , slotsSelected = slotsSelectedInit
      , songsCurrent = songsCurrentInit
      , songsLike = Set.empty
      , timeNow = Time.millisToPosix 0
      }
    , Cmd.none
    )


slotsSelectedInit : SlotsSelected
slotsSelectedInit =
    Array.repeat slotsCount False



-- APPLICATION-SPECIFIC


type alias AppendJsonRoot =
    { response : String }


type alias AppendResponseString =
    String


type alias Artist =
    String


type alias Channel =
    String


type alias Class =
    String


type alias LatestFiveJsonRoot =
    { latestFive : Songs }


type alias SlotsSelected =
    Array.Array Bool


type alias SlotTouchIndex =
    Int


type alias Song =
    { artist : Artist
    , time : SongTime
    , title : Title
    }


type alias Songs =
    List Song


type alias SongsLike =
    Set.Set Song


type alias SongTime =
    String


type alias Title =
    String


type DirectionLike
    = SendLike
    | SendUnlike


type OverallState
    = TimerActive
    | TimerIdle


slotsCount : Int
slotsCount =
    5



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        timer : Sub Msg
        timer =
            case model.overallState of
                TimerIdle ->
                    Sub.none

                TimerActive ->
                    let
                        milliseconds : Float
                        milliseconds =
                            toFloat (model.delaySeconds * 1000)

                        timeNotSet : Bool
                        timeNotSet =
                            Time.posixToMillis model.timeNow < 1000
                    in
                    if timeNotSet then
                        Sub.none

                    else
                        --The first tick happens after the delay.
                        Time.every milliseconds GotTimer
    in
    timer
