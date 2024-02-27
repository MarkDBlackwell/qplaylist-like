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
    , songsLiked : Songs
    , unlikesToProcess : Songs
    }


type alias Song =
    { artist : Artist
    , title : Title
    }


type alias Songs =
    List Song


type alias Title =
    String


type Msg
    = GotAppendResponse (Result Http.Error String)
    | GotSongsResponse (Result Http.Error String)
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
      , songsLiked = songsLikedInit
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


songsLikedInit : List Song
songsLikedInit =
    [ Song "Bob" "Highway 51 Revisited"
    , Song "Alice" "Wonderland"
    ]
