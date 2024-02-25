module Main exposing (main)

import View


--See:
--https://elm-lang.org/examples/clock


main =
    View.view 0


type alias Model =
  { something : Int
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( Model 0
  , Cmd.batch [ ]
  )


-- UPDATE


type Msg
  = Nothing


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Nothing ->
      ( { model }
      , Cmd.none
      )

subscriptions : Model -> Sub Msg
subscriptions model =
  Nothing



-- VIEW


--cmdLikeRequest =
--Http.post
--etc.
{-
   import Http

   type ActionLikeOrComment
       = Comment
       | Like

   type Msg
       = MsgLikeResponse ResultErrorHttp
       | MsgSongsRecentResponse ResultErrorHttp

   type alias HttpResponseText =
       String

   type alias LikeResponseText =
       String

   type alias LikeResponseWithDummyTag =
       --TODO: Why do we need a tag?
       { dummyTag : LikeResponseText }

   type alias ResultErrorHttp =
       Result Http.Error HttpResponseText

   type alias SongsRecentWithDummyTag =
       --TODO: Why do we need a tag?
       { dummyTag : SongsRecent }


   cmdLikeRequest =
       Http.get
           { url = likeRequestUrlText
           , expect =
               MsgLikeResponse
                   |> Http.expectString
           }

   decodeLikeResponse : HttpResponseText -> Result AlertMessageText LikeResponseText
   decodeLikeResponse jsonRawText =
       --For decoding JSON:
       let
           asRecord : Result Json.Decode.Error LikeResponseWithDummyTag
           asRecord =
               let
                   decodeResponse : Json.Decode.Decoder LikeResponseWithDummyTag
                   decodeResponse =
                       let
                           tag : String
                           tag =
                               "response"
                       in
                       tag
                           |> field2String
                           |> Json.Decode.map
                               LikeResponseWithDummyTag
               in
               jsonRawText
                   |> Json.Decode.decodeString
                       decodeResponse
       in
       case asRecord of
           Err error ->
               error
                   |> (Json.Decode.errorToString >> Err)

           Ok record ->
               Ok record.dummyTag

   decodeSongsRecentResponse : HttpResponseText -> Result AlertMessageText SongsRecent
   decodeSongsRecentResponse jsonRawText =
       --See:
       --  http://medium.com/@eeue56/json-decoding-in-elm-is-still-difficult-cad2d1fb39ae
       --  http://eeue56.github.io/json-to-elm/
       --For decoding JSON:
       let
           asRecord : Result Json.Decode.Error SongsRecentWithDummyTag
           asRecord =
               let
                   decodeSongsRecentWithDummyTag : Json.Decode.Decoder SongsRecentWithDummyTag
                   decodeSongsRecentWithDummyTag =
                       let
                           decodeSongRecent : Json.Decode.Decoder SongRecent
                           decodeSongRecent =
                               Json.Decode.map4
                                   SongRecent
                                   (field2String "artist")
                                   (field2String "time")
                                   (field2String "timeStamp")
                                   (field2String "title")

                           tag : String
                           tag =
                               "latestFive"
                       in
                       decodeSongRecent
                           |> Json.Decode.list
                           |> Json.Decode.field tag
                           |> Json.Decode.map
                               SongsRecentWithDummyTag
               in
               jsonRawText
                   |> Json.Decode.decodeString
                       decodeSongsRecentWithDummyTag
       in
       case asRecord of
           Err error ->
               error
                   |> (Json.Decode.errorToString >> Err)

           Ok record ->
               Ok record.dummyTag


   likeResponseErr : Model -> Http.Error -> ActionLikeOrComment -> ElmCycle.ElmCycle
   likeResponseErr model httpError actionLikeOrComment =
       let
           alertLikeOrComment : AlertType.LikeOrCommentName -> AlertMessageText
           alertLikeOrComment =
               httpError
                   |> Alert.messageTextRequestLikeOrComment

           modelNewSongLikingOrCommentingOnNow : Model
           modelNewSongLikingOrCommentingOnNow =
               case actionLikeOrComment of
                   Comment ->
                       model

                   Like ->
                       { model
                           | songLikingNowMaybe = SongInitialize.songLikingNowMaybeInit
                       }
       in
       ( { modelNewSongLikingOrCommentingOnNow
           | alertMessageText =
               actionLikeOrComment
                   |> (UpdateHelper.actionLikeOrComment2String >> alertLikeOrComment >> Just)
           , awaitingServerResponse = ModelInitialize.awaitingServerResponseInit
         }
       , Cmd.batch
           [ actionLikeOrComment
               |> (UpdateHelper.actionLikeOrComment2String >> alertLikeOrComment)
               |> String.append
                   (httpError
                       |> alertLogging
                   )
               |> (Just >> LogUpdate.cmdLogResponse)
           , FocusUpdate.cmdFocusInputPossibly model
           ]
       )



   likeResponseOk : Model -> HttpResponseText -> ActionLikeOrComment -> ElmCycle.ElmCycle
   likeResponseOk model httpResponseText actionLikeOrComment =
       let
           actionDescription : AlertMessageText
           actionDescription =
               actionLikeOrComment
                   |> UpdateHelper.actionLikeOrComment2String
                   |> String.append "send your "

           cmdButtonCommand : Cmd ElmCycle.Msg
           cmdButtonCommand =
               case actionLikeOrComment of
                   Comment ->
                       Cmd.none

                   Like ->
                       cmdButtonCommandAccomplished

           cmdButtonCommandAccomplished : Cmd ElmCycle.Msg
           cmdButtonCommandAccomplished =
               actionLikeOrComment
                   |> UpdateHelper.actionLikeOrComment2String
                   |> SongHelper.buttonIdReconstruct
                       model.songsRemembered
                       songLikingOrCommentingOnNowMaybe
                   |> FocusUpdate.cmdFocusSetId

           modelNewCommentText : Model
           modelNewCommentText =
               case actionLikeOrComment of
                   Comment ->
                       { modelNewSongLikingOrCommentingOnNow
                           | commentText = ModelInitialize.commentTextInit
                       }

                   Like ->
                       modelNewSongLikingOrCommentingOnNow

           modelNewSongLikingOrCommentingOnNow : Model
           modelNewSongLikingOrCommentingOnNow =
               case actionLikeOrComment of
                   Comment ->
                       { model
                           | songCommentingOnNowMaybe = SongInitialize.songCommentingOnNowMaybeInit
                       }

                   Like ->
                       { model
                           | songLikingNowMaybe = SongInitialize.songLikingNowMaybeInit
                       }

           songLikingOrCommentingOnNowMaybe : SongRememberedMaybe
           songLikingOrCommentingOnNowMaybe =
               case actionLikeOrComment of
                   Comment ->
                       model.songCommentingOnNowMaybe

                   Like ->
                       model.songLikingNowMaybe
       in
       case LikeOrCommentResponseDecode.decodeLikeResponse httpResponseText of
           Err alertMessageTextDecode ->
               ( { model
                   | alertMessageText =
                       alertMessageTextDecode
                           |> Alert.messageTextSend actionDescription
                           |> Just

                   , awaitingServerResponse = ModelInitialize.awaitingServerResponseInit
                 }
               , Cmd.batch
                   [ httpResponseText
                       |> String.append alertMessageTextDecode
                       |> (Just >> LogUpdate.cmdLogDecoding)
                   , cmdButtonCommand
                   , FocusUpdate.cmdFocusInputPossibly model
                   ]
               )

           Ok responseText ->
               let
                   serverSaysRequestWasBad : Bool
                   serverSaysRequestWasBad =
                       "good" /= responseText
               in
               if serverSaysRequestWasBad then
                   ( { modelNewSongLikingOrCommentingOnNow
                       | alertMessageText =
                           responseText
                               |> Alert.messageTextSend actionDescription
                               |> Just
                       , awaitingServerResponse = ModelInitialize.awaitingServerResponseInit
                     }
                   , Cmd.batch
                       [ httpResponseText
                           |> String.append responseText
                           |> (Just >> LogUpdate.cmdLogResponse)
                       , cmdButtonCommand
                       , FocusUpdate.cmdFocusInputPossibly model
                       ]
                   )

               else
                   let
                       songsRememberedNew : SongsRemembered
                       songsRememberedNew =
                           model.songsRemembered
                               |> Song.likedOrCommentedShow
                                   songLikingOrCommentingOnNowMaybe
                   in
                   ( { modelNewCommentText
                       | alertMessageText = Alert.messageTextInit
                       , awaitingServerResponse = ModelInitialize.awaitingServerResponseInit
                       , songsRemembered = songsRememberedNew
                     }
                   , Cmd.batch
                       [ MsgSongsRememberedStore
                           |> cmdMsg2Cmd
                       , LogUpdate.cmdLogResponse Nothing
                       , cmdButtonCommandAccomplished
                       , FocusUpdate.cmdFocusInputPossibly model
                       ]
                   )


   songsRecentResponseErr : Model -> Http.Error -> ElmCycle.ElmCycle
   songsRecentResponseErr model httpError =
       let
           alertMessageTextNew : AlertMessageText
           alertMessageTextNew =
               let
                   alertScreen : String
                   alertScreen =
                       httpError
                           |> Alert.messageTextErrorHttpScreen
               in
               String.concat
                   [ alertScreen
                   , " (while attempting to "
                   , Alert.actionDescriptionRecent
                   , ")"
                   ]
       in
       ( { model
           | alertMessageText = Just alertMessageTextNew
           , awaitingServerResponse = ModelInitialize.awaitingServerResponseInit
         }
       , Cmd.batch
           [ httpError
               |> (alertLogging >> Just >> LogUpdate.cmdLogResponse)
           , FocusUpdate.cmdFocusInputPossibly model
           ]
       )

   songsRecentResponseOk : Model -> HttpResponseText -> ElmCycle.ElmCycle
   songsRecentResponseOk model httpResponseText =
       case SongsRecentDecode.decodeSongsRecentResponse httpResponseText of
           Err alertMessageTextDecode ->
               ( { model
                   | alertMessageText =
                       alertMessageTextDecode
                           |> Alert.messageTextSend Alert.actionDescriptionRecent
                           |> Just
                   , awaitingServerResponse = ModelInitialize.awaitingServerResponseInit
                 }
               , Cmd.batch
                   [ httpResponseText
                       |> String.append alertMessageTextDecode
                       |> (Just >> LogUpdate.cmdLogDecoding)
                   , FocusUpdate.cmdFocusInputPossibly model
                   ]
               )

           Ok songsRecentNew ->
               ( { model
                   | alertMessageText = Alert.messageTextInit
                   , awaitingServerResponse = ModelInitialize.awaitingServerResponseInit
                   , songsRecent = songsRecentNew
                 }
                 --Here, don't log the full response.
               , Cmd.batch
                   [ LogUpdate.cmdLogResponse Nothing
                   , FocusUpdate.cmdFocusInputPossibly model
                   ]
               )

   -- UPDATE


   update : ElmCycle.Msg -> Model -> ElmCycle.ElmCycle
   update msg model =
       case msg of
           MsgLikeResponse (Err httpError) ->
               Like
                   |> ResponseUpdate.likeOrCommentResponseErr model httpError

           MsgLikeResponse (Ok httpResponseText) ->
               Like
                   |> ResponseUpdate.likeOrCommentResponseOk model httpResponseText

           MsgLikeSendHand songsRememberedIndex ->
               songsRememberedIndex
                   |> RequestUpdate.likeSendHand model

           MsgNone ->
               UpdateHelper.elmCycleDefault model

           MsgUnlikeSendHand songsRememberedIndex ->
               songsRememberedIndex
                   |> RequestUpdate.UnlikeSendHand model

           MsgSongsRecentRefreshHand ->
               RequestUpdate.songsRecentRefreshHand model

           MsgSongsRecentResponse (Err httpError) ->
               httpError
                   |> ResponseUpdate.songsRecentResponseErr model

           MsgSongsRecentResponse (Ok httpResponseText) ->
               httpResponseText
                   |> ResponseUpdate.songsRecentResponseOk model

-}
