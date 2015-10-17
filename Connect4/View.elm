module Connect4.View (view) where

import Elm-Html exposing (..)
import Elm-Attribute exposing (..)

import Signal as S
import List as L

import Connect4.Model exposing (..)

view : S.Address Action -> Model -> Html
view address model = 
  let
    makeSpace : Space -> Html
    makeSpace space =
      case space.status of
        Empty -> div [ class "empty",
                 onClick address (MakeMove space.id) ] []
        Red -> div [class "x"]
          [text "X"]
        Blue -> div [class "o"]
          [text "O"]
    
    winnerToString : Maybe Player -> String
    winnerToString winner =
      case winner of
        Nothing -> "Nobody won.. -.-"
        Just Player1 -> "Player 1 won! XD"
        Just Player2 -> "Player 2 won! XD"

  in
    div [] 
      [ div [id "board"] (L.map makeSpace model.board)
      , div [class "notice"] 
          (case model.gameOver of
            False -> [text "Connect 4"]
            True ->
              [ ul []
                [ li [] [text "game over"]
                , li [] [text <| winnerToString model.winner]
                , li [] [text "click refresh to try again"] ]
              ]
          )
        ]
