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
    , overallState : OverallState
    , slotsSelected : SlotsSelected
    , songsCurrent : Songs
    , songsLike : SongsLike
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
    | GotTimeTick Time.Posix
    | GotTouchEvent SlotTouchIndex


type OverallState
    = TimerActive
    | TimerIdle


slotsCount : Int
slotsCount =
    5



-- INITIALIZATION


init : Channel -> ( Model, Cmd Msg )
init channel =
    ( { channel = channel
      , overallState = TimerIdle
      , slotsSelected = slotsSelectedInit
      , songsCurrent = songsCurrentInit
      , songsLike = songsLikeInit
      }
    , Cmd.none
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
