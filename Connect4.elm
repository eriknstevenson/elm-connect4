module Connect4 where

{-| A simple reimagination of the classic game, using the HTML module.

#Functions
@docs view, update

-}

import Html exposing (..)
import Html.Events exposing (..)
import Signal as S

import Connect4.Model exposing (..)
import Connect4.Update exposing (..)
import Connect4.View exposing (..)
import Connect4.Util exposing (..)


inbox : Signal.Mailbox Action
inbox = Signal.mailbox None


main : Signal Html
main =
  let
    model = S.foldp update initialModel inbox.signal
  in
    S.map (view inbox.address) model

       
