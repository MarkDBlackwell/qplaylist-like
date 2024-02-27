module Model exposing (..)

import Http
import Task


type alias AppendJsonRoot =
    { response : String }


type alias Artist =
    String


type alias Class =
    String


type alias LatestFiveJsonRoot =
    { latestFive : List Song }


type alias Model =
    { likesToProcess : Songs
    , overallState : OverallState
    , songsCurrent : Songs
    , songsLike : Songs
    , unlikesToProcess : Songs
    }


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
    = GotAppendResponse (Result Http.Error StringJson)
    | GotSongsResponse (Result Http.Error StringJson)
    | GotTouchEvent


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


init : () -> ( Model, Cmd Msg )
init _ =
    ( { likesToProcess = []
      , overallState = Idle
      , songsCurrent = songsCurrentInit
      , songsLike = songsLikeInit
      , unlikesToProcess = []
      }
    , cmdMsg2Cmd GotTouchEvent
    )


songsCurrentInit : List Song
songsCurrentInit =
    [ Song "Charlie" "Chan"
    , Song "Alice" "Wonderland"
    , Song "Dave" "Brubeck"
    , Song "Frank" "Diary"
    , Song "Edger" "A. Poe"
    ]


songsLikeInit : List Song
songsLikeInit =
    [ Song "Bob" "Highway 51 Revisited"
    , Song "Alice" "Wonderland"
    ]
