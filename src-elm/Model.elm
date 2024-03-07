module Model exposing (..)

import Array
import AssocSet as Set
import Http
import Time


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


type alias Model =
    { channel : Channel
    , delaySeconds : Int
    , overallState : OverallState
    , slotsSelected : SlotsSelected
    , songsCurrent : Songs
    , songsLike : SongsLike
    , timeStart : Time.Posix
    }


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


type Msg
    = GotAppendResponse (Result Http.Error AppendResponseString)
    | GotSongsResponse (Result Http.Error Songs)
    | GotTimeStart Time.Posix
    | GotTimeTick Time.Posix
    | GotTouchEvent SlotTouchIndex


type OverallState
    = TimerActive
    | TimerIdle


delaySecondsFirst : Time.Posix -> Int
delaySecondsFirst timeStart =
    let
        secondsStart : Int
        secondsStart =
            Time.posixToMillis timeStart // 1000

        secondsOver : Int
        secondsOver =
            secondsStart
                |> modBy delaySecondsStandard
    in
    delaySecondsStandard - secondsOver


delaySecondsStandard : Int
delaySecondsStandard =
    60


slotsCount : Int
slotsCount =
    5



-- INITIALIZATION


init : Channel -> ( Model, Cmd Msg )
init channel =
    ( { channel = channel
      , delaySeconds = 0
      , overallState = TimerIdle
      , slotsSelected = slotsSelectedInit
      , songsCurrent = songsCurrentInit
      , songsLike = songsLikeInit
      , timeStart = Time.millisToPosix 0
      }
    , Task.perform GotTimeStart Time.now
    )


slotsSelectedInit : SlotsSelected
slotsSelectedInit =
    Array.repeat slotsCount False


songsCurrentInit : Songs
songsCurrentInit =
    let
        songEmpty : Song
        songEmpty =
            Song "" "" ""
    in
    List.repeat slotsCount songEmpty


songsLikeInit : SongsLike
songsLikeInit =
    Set.empty



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        timer : Sub Msg
        timer =
            let
                milliseconds : Float
                milliseconds =
                    toFloat (model.delaySeconds * 1000)
            in
            if Time.posixToMillis model.timeStart < 1000 then
                Sub.none

            else
                --The first tick happens after the delay.
                Time.every milliseconds GotTimeTick

        timerOld : Sub Msg
        timerOld =
            case model.overallState of
                TimerIdle ->
                    Sub.none

                TimerActive ->
                    let
                        delaySeconds : Float
                        delaySeconds =
                            20.0
                    in
                    --The first tick happens after the delay.
                    Time.every (delaySeconds * 1000.0) GotTimeTick
    in
    timer
