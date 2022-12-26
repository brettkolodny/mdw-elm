module Routes.Send.Model exposing (..)

import Session.Model exposing (Account)


type alias Model =
    { fromAccount : Maybe Account
    , toAddress : String
    , toAddressValid : Bool
    , showToAddressSelection : Bool
    , showFromAddressSelection : Bool
    , sendAmount : Maybe Float
    }
