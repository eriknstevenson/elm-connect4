module Connect4.Update (update) where

import List as L
import List.Extra as LE
import Maybe as M
import Debug

import Connect4.Model exposing (..)
import Connect4.Util exposing (..)


update : Action -> Model -> Model
update action model =
  case action of
    None -> model
    
    MakeMove id ->
      let

        idToUpdate =
          let
            openSpace = findOpenSpace column
            column = id % 7
            findOpenSpace at =
              case (model.board !! at) of
                Nothing ->
                  at - 7
                Just space ->
                  case space.status of
                    Empty ->
                      -- occupied, increment index by 7.
                      findOpenSpace (at + 7)
                    _ ->
                      at - 7
          in
            if openSpace < 0 then Nothing else Just openSpace
        
        validMove =
          case idToUpdate of
            Nothing -> False
            _ -> True
        
        
        newStatus = case model.turn of 
          Player1 -> Red
          Player2 -> Blue

        updatedBoard =
          let
            updateStatus space =
              case idToUpdate of
                Nothing -> space
                Just id ->
                  if space.id == id then 
                    { space | status <- newStatus} 
                  else 
                    space
          in
            L.map updateStatus model.board


        checkForWinner =
          let
            checks =
              let
                checkVerticals index =
                  L.sum [ checkDir index -7 1
                        , checkDir index  7 1 ] - 1

                checkHorizontals index =
                  L.sum [ checkDir index -1 1
                        , checkDir index  1 1 ] - 1

                checkDiagonalsA index =
                  L.sum [ checkDir index -8 1
                        , checkDir index  8 1 ] - 1
        
                checkDiagonalsB index =
                  L.sum [ checkDir index -6 1
                        , checkDir index  6 1 ] - 1  
              in
                case idToUpdate of
                  Nothing -> []
                  Just id ->
                    apply id
                            [ checkVerticals
                            , checkHorizontals
                            , checkDiagonalsA
                            , checkDiagonalsB ]
                
            isThereAWinner = checks
                         |> L.filter (\n -> n >= 4)
                         |> L.isEmpty
                         |> not
          in
            case isThereAWinner of
              True -> Just model.turn
              False -> Nothing
                       
                       
        checkDir : Int -> Int -> Int -> Int
        checkDir index increment total = 
          case updatedBoard !! (index + increment) of
            Nothing -> total
            Just space -> 
              if space.status == newStatus then
                checkDir (index + increment) (increment) (total+1)
              else
                total
        
        updatedGameOver =
          let
            updatedBoardStatus = L.map .status updatedBoard
          in
            (updatedBoardStatus |> LE.notMember Empty ) || checkForWinner /= Nothing

        toggleTurn : Player -> Player
        toggleTurn player = 
          case validMove of
            True ->
              case player of
                Player1 -> Player2
                Player2 -> Player1
            False -> player
    
      in case model.gameOver of
        False -> {model | board <- updatedBoard
                        , turn <- (toggleTurn model.turn)
                        , winner <- checkForWinner
                        , gameOver <- updatedGameOver }
        True -> model
