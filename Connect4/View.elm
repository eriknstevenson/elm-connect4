module Connect4.View (view) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal as S
import List as L
import Maybe as M

import Connect4.Model exposing (..)

view : S.Address Action -> Model -> Html
view address model = 
  let
    makeSpace : Space -> Html
    makeSpace space =
      case space.status of
        Empty -> div [ class "empty"
                     , onClick address (MakeMove space.id) ] []
        Red -> div [ class "red"
                   , onClick address (MakeMove space.id) ] []
        Blue -> div [ class "blue"
                    , onClick address (MakeMove space.id) ] []

    currentTurn : String
    currentTurn =
      case model.turn of
        Player1 -> "Red"
        Player2 -> "Blue"
      
    winnerToString : Maybe Player -> String
    winnerToString winner =
      case winner of
        Nothing -> "Nobody won.. -.-"
        Just Player1 -> "Player 1 won! XD"
        Just Player2 -> "Player 2 won! XD"

  in
    div [] 
      [ div [class "notice"] 
          (case model.gameOver of
            False -> [ text "Connect 4 - "
                     , text currentTurn
                     , text "'s Turn" ]
            True ->
              [ ul []
                [ li [] [text "game over"]
                , li [] [text <| winnerToString model.winner]
                , li [] [text "click refresh to try again"] ]
              ]
          )
      , div [id "board"] (L.map makeSpace model.board)
      ]
