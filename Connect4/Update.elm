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
            findOpenSpace column
        
        validMove =
          if idToUpdate >= 0 then True else False
        
        
        newStatus = case model.turn of 
          Player1 -> Red
          Player2 -> Blue

        updatedBoard =
          let
            updateStatus space = 
              if space.id==idToUpdate then 
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
                case validMove of
                  False -> []
                  True ->
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
            Just spc -> 
              if spc.status  == newStatus then
                let
                  _ = Debug.log "match found at i " (spc)
                in
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
          if id > 0 then
            case player of
              Player1 -> Player2
              Player2 -> Player1
          else player
    
      in case model.gameOver of
        False -> {model | board <- updatedBoard
                        , turn <- (toggleTurn model.turn)
                        , winner <- checkForWinner
                        , gameOver <- updatedGameOver }
        True -> model
