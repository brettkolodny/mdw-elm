module Routes.Send.Model exposing (..)

import Session.Model exposing (Account)


type alias Model =
    { fromAccount : Maybe Account
    , toAddress : String
    , toAddressValid : Bool
    , showToAddressSelection : Bool
    , showFromAddressSelection : Bool
    , sendAmount : Maybe Float
    , transactionPreview : Int
    , verifyTransaction : Bool
    , confirming : Bool
    , confirmed: Bool
    }


model : Model
model =
    { toAddress = ""
    , fromAccount = Nothing
    , toAddressValid = False
    , showToAddressSelection = False
    , showFromAddressSelection = False
    , sendAmount = Nothing
    , transactionPreview = 0
    , verifyTransaction = False
    , confirming = False
    , confirmed = False
    }
