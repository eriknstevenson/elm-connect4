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

        validMove =
          True
        
        -- id : the id # of the space that is the lowest, empty space in the clicked column.
        {- id =
          let
            boardGrid = convertTo2D model.board 7
            xyToId x y = (y*7) + x + 1
            newId = xyToId findX (findY 0)
            findX = column
            findY y =
              case (getBoardXY boardGrid column y) of
                Nothing ->
                  -- gone off the board
                  y-1
                Just spc ->
                  case spc.status of
                    Empty ->
                      -- space is unoccupied, check the next one down.
                      findY (y+1)
                    _ ->
                      -- space is occupied, return the id of the previous space checked
                      y-1
                  
          in
            if newId > 0 then newId else -1
        -}
        
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
                       
                       
        checkDir : Int -> (Int, Int) -> Int -> Int
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
